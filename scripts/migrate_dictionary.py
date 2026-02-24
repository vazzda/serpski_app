#!/usr/bin/env python3
"""
Migration script: verbs.json → new multi-language dictionary structure.

Generates:
  assets/data/dictionary.json
  assets/data/translations/en.json
  assets/data/translations/sr.json
  assets/data/translations/ru.json  (partial stub)
  assets/data/tools/sr/conjugations.json
"""

import json
import re
import os
from collections import OrderedDict

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)
INPUT_FILE = os.path.join(PROJECT_ROOT, "assets", "data", "verbs.json")
OUTPUT_DIR = os.path.join(PROJECT_ROOT, "assets", "data")

# Manual dedup: same Serbian word appearing with different English phrasings.
# Maps (serbian_word, english_clean_to_drop) → english_clean_to_keep.
# The "to_drop" entry is merged into the "to_keep" concept (with alt note).
DEDUP_MAP = {
    ("podići", "to lift"): "to raise",
    ("početi", "to start"): "to begin",
    ("dopustiti", "to allow"): "to let",
    ("nastaviti", "to carry on"): "to continue",
    ("reći", "to tell"): "to say",
    ("ustati", "to stand up"): "to get up",
}


def parse_english_text(english_raw):
    """
    Parse English text to extract:
      - clean text (base meaning, no parenthetical notes, no aspect marker)
      - note (parenthetical content, excluding (pf.))
      - is_perfective (True if (pf.) present)

    Examples:
      "to buy (purchase) (pf.)" → ("to buy", "purchase", True)
      "to hold (grip)" → ("to hold", "grip", False)
      "to run (move fast)" → ("to run", "move fast", False)
      "to hate" → ("to hate", None, False)
      "to win (be victorious) / to get (obtain/receive) (pf.)" → ("to win / to get", "be victorious / obtain/receive", True)
    """
    text = english_raw.strip()

    # Check for (pf.) and remove it
    is_perfective = "(pf.)" in text
    text = text.replace("(pf.)", "").strip()

    # Extract all parenthetical notes
    notes = re.findall(r'\(([^)]+)\)', text)
    # Remove parentheticals from text
    clean = re.sub(r'\s*\([^)]*\)', '', text).strip()
    # Clean up double spaces
    clean = re.sub(r'\s+', ' ', clean)

    note = " / ".join(notes) if notes else None
    return clean, note, is_perfective


def generate_concept_id(english_clean, category, existing_ids):
    """
    Generate a human-readable concept ID from clean English text.

    Rules:
      - Lowercase, underscores for spaces
      - Strip "to " prefix for verbs
      - Handle "/" alternatives: use first one
      - Ensure uniqueness
    """
    text = english_clean.lower().strip()

    # For verbs, strip "to " prefix
    if text.startswith("to "):
        text = text[3:]

    # If multiple alternatives (a / b), use first
    if " / " in text:
        text = text.split(" / ")[0].strip()

    # Replace special chars
    text = text.replace("-", "_")
    text = re.sub(r'[^a-z0-9_ ]', '', text)
    text = text.strip()
    text = re.sub(r'\s+', '_', text)

    # Ensure uniqueness
    base_id = text
    if base_id in existing_ids:
        # Add POS qualifier
        qualifier = category[0] if category else "x"
        candidate = f"{base_id}_{qualifier}"
        if candidate in existing_ids:
            counter = 2
            while f"{candidate}_{counter}" in existing_ids:
                counter += 1
            candidate = f"{candidate}_{counter}"
        base_id = candidate

    return base_id


def map_category_to_pos(category):
    """Map verbs.json category to universal POS."""
    mapping = {
        "verb": "verb",
        "noun": "noun",
        "adjective": "adjective",
        "other": "other",
    }
    return mapping.get(category, "other")


def process_vocabulary_groups(data):
    """
    Process all type:"words" groups.
    Returns: concepts dict, groups list, en translations, sr translations.
    """
    concepts = OrderedDict()
    groups = []
    en_translations = OrderedDict()
    sr_translations = OrderedDict()

    existing_concept_ids = set()

    # Track serbian words to detect duplicates
    serbian_to_concepts = {}

    # First pass: identify aspect pairs by matching English text
    # Build a map: english_clean_lower → list of card info
    english_to_cards = {}

    for group in data:
        if group["type"] != "words":
            continue
        for card in group["cards"]:
            english_raw = card["english"]
            english_clean, note, is_pf = parse_english_text(english_raw)
            key = english_clean.lower()
            if key not in english_to_cards:
                english_to_cards[key] = []
            english_to_cards[key].append({
                "card": card,
                "group_id": group["id"],
                "category": group.get("category"),
                "english_clean": english_clean,
                "note": note,
                "is_pf": is_pf,
            })

    # Identify aspect pairs: same english_clean, one pf and one not
    aspect_pairs = {}
    for key, cards in english_to_cards.items():
        pf_cards = [c for c in cards if c["is_pf"]]
        impf_cards = [c for c in cards if not c["is_pf"]]
        if pf_cards and impf_cards:
            aspect_pairs[key] = {
                "pf": pf_cards[0],
                "impf": impf_cards[0],
            }
            if len(pf_cards) > 1:
                print(f"  WARNING: Multiple pf forms for '{key}': {[c['card']['serbian'] for c in pf_cards]}")
            if len(impf_cards) > 1:
                print(f"  WARNING: Multiple impf forms for '{key}': {[c['card']['serbian'] for c in impf_cards]}")

    print(f"  Found {len(aspect_pairs)} aspect pairs")

    # Track which cards have been consumed by aspect pairs
    consumed_cards = set()
    for key, pair in aspect_pairs.items():
        consumed_cards.add((pair["pf"]["group_id"], pair["pf"]["card"]["serbian"]))
        consumed_cards.add((pair["impf"]["group_id"], pair["impf"]["card"]["serbian"]))

    # Create concepts for aspect pairs first
    # Assign to the group of the imperfective form (more common/base form)
    aspect_pair_concepts = {}  # english_clean_lower → concept_id
    aspect_pair_group = {}     # concept_id → group_id (impf group)

    for key, pair in aspect_pairs.items():
        impf = pair["impf"]
        pf = pair["pf"]
        category = impf["category"] or pf["category"]
        pos = map_category_to_pos(category)

        concept_id = generate_concept_id(impf["english_clean"], category, existing_concept_ids)
        existing_concept_ids.add(concept_id)
        aspect_pair_concepts[key] = concept_id
        aspect_pair_group[concept_id] = impf["group_id"]

        concepts[concept_id] = {"pos": pos}

        # English translation — one entry
        en_entry = {"text": impf["english_clean"]}
        if impf["note"]:
            en_entry["note"] = impf["note"]
        en_translations[concept_id] = [en_entry]

        # Serbian translations — two entries (imperfective first, then perfective)
        impf_entry = {"text": impf["card"]["serbian"], "aspect": "imperfective"}
        pf_entry = {"text": pf["card"]["serbian"], "aspect": "perfective"}
        sr_translations[concept_id] = [impf_entry, pf_entry]

        print(f"  ASPECT PAIR: {concept_id} → {impf['card']['serbian']} (impf) + {pf['card']['serbian']} (pf)")

    # Second pass: process each group
    for group in data:
        if group["type"] != "words":
            continue

        group_concept_ids = []

        # First, add aspect pair concepts that have their impf form in this group
        for cid, gid in aspect_pair_group.items():
            if gid == group["id"]:
                group_concept_ids.append(cid)

        for card in group["cards"]:
            serbian = card["serbian"]

            # Skip if consumed by aspect pair
            if (group["id"], serbian) in consumed_cards:
                continue

            english_raw = card["english"]
            english_clean, note, is_pf = parse_english_text(english_raw)
            category = group.get("category")
            pos = map_category_to_pos(category)

            # Check dedup map: if this is a "to_drop" entry, skip it
            dedup_key = (serbian, english_clean)
            if dedup_key in DEDUP_MAP:
                keep_english = DEDUP_MAP[dedup_key]
                print(f"  DEDUP: '{serbian}' ({english_clean}) merged into '{keep_english}'")
                # Find the kept concept and add to this group
                for cid, _gid, _eng in serbian_to_concepts.get(serbian, []):
                    if cid not in group_concept_ids:
                        group_concept_ids.append(cid)
                continue

            # Check for serbian duplicates (same word already processed)
            if serbian in serbian_to_concepts:
                prev = serbian_to_concepts[serbian]
                prev_concept = prev[0][0]
                prev_english = prev[0][2]
                if english_clean.lower() == prev_english.lower():
                    # Same word, same meaning — skip duplicate, but add concept to group
                    print(f"  DUPLICATE SKIPPED: '{serbian}' ({english_clean}) in {group['id']}, already as '{prev_concept}'")
                    if prev_concept not in group_concept_ids:
                        group_concept_ids.append(prev_concept)
                    continue
                else:
                    # Check if this is a known dedup (the other direction)
                    reverse_key = (serbian, prev_english)
                    if reverse_key in DEDUP_MAP:
                        # The previously added one was the "drop" — this shouldn't happen
                        # because we process groups in order and DEDUP_MAP drops the second occurrence
                        pass
                    else:
                        print(f"  HOMONYM: '{serbian}' → '{english_clean}' AND '{prev_english}'")

            concept_id = generate_concept_id(english_clean, category, existing_concept_ids)
            existing_concept_ids.add(concept_id)

            concepts[concept_id] = {"pos": pos}

            # English translation
            en_entry = {"text": english_clean}
            if note:
                en_entry["note"] = note
            en_translations[concept_id] = [en_entry]

            # Serbian translation
            sr_entry = {"text": serbian}
            if is_pf:
                sr_entry["aspect"] = "perfective"
            if category == "noun" and "gender" in card:
                sr_entry["gender"] = card["gender"]
            if category == "adjective":
                sr_entry["gender"] = "m"
                forms = {}
                if "feminine" in card:
                    forms["f"] = card["feminine"]
                if "neuter" in card:
                    forms["n"] = card["neuter"]
                if forms:
                    sr_entry["forms"] = forms
            sr_translations[concept_id] = [sr_entry]

            serbian_to_concepts.setdefault(serbian, []).append(
                (concept_id, group["id"], english_clean)
            )
            group_concept_ids.append(concept_id)

        if group_concept_ids:
            groups.append({
                "id": group["id"],
                "labelKey": group["labelKey"],
                "concepts": group_concept_ids,
            })

    return concepts, groups, en_translations, sr_translations


def process_endings_groups(data):
    """
    Process all type:"endings" groups into tools/sr/conjugations.json format.
    """
    conj_groups = []

    for group in data:
        if group["type"] != "endings":
            continue

        cards = group["cards"]
        verbs = []
        for i in range(0, len(cards), 6):
            block = cards[i:i+6]
            if len(block) < 6:
                print(f"  WARNING: Incomplete verb block in {group['id']} at index {i}")
                continue

            # Derive English base from "ja" form: "i count" → "count"
            english_base = block[0]["english"]
            eng_verb = english_base
            if eng_verb.lower().startswith("i "):
                eng_verb = eng_verb[2:]
            eng_verb = eng_verb.replace(" (pf.)", "").strip()

            forms = OrderedDict()
            for card in block:
                forms[card["pronoun"]] = card["serbian"]

            verb_entry = {
                "englishBase": eng_verb,
                "forms": dict(forms),
            }
            verbs.append(verb_entry)

        conj_groups.append({
            "id": group["id"],
            "labelKey": group["labelKey"],
            "verbs": verbs,
        })

    return {"groups": conj_groups}


def generate_ru_stub(en_translations, fraction=0.75):
    """
    Generate a partial Russian translation file for testing incomplete dict UI.
    Placeholder entries — NOT real Russian translations.
    Only covers `fraction` of concepts.
    """
    ru = OrderedDict()
    all_ids = list(en_translations.keys())
    count = int(len(all_ids) * fraction)
    for cid in all_ids[:count]:
        ru[cid] = [{"text": f"[RU:{cid}]"}]
    return ru


def main():
    print(f"Reading {INPUT_FILE}...")
    with open(INPUT_FILE, "r", encoding="utf-8") as f:
        data = json.load(f)

    print(f"Found {len(data)} groups total")
    word_groups = [g for g in data if g["type"] == "words"]
    ending_groups = [g for g in data if g["type"] == "endings"]
    print(f"  Word groups: {len(word_groups)}")
    print(f"  Ending groups: {len(ending_groups)}")

    # Process vocabulary
    print("\n--- Processing vocabulary groups ---")
    concepts, groups, en_trans, sr_trans = process_vocabulary_groups(data)
    print(f"\nExtracted {len(concepts)} unique concepts across {len(groups)} groups")

    # Process endings
    print("\n--- Processing endings groups ---")
    conjugations = process_endings_groups(data)
    print(f"Extracted {len(conjugations['groups'])} conjugation groups")

    # Generate Russian stub
    print("\n--- Generating Russian stub ---")
    ru_trans = generate_ru_stub(en_trans, fraction=0.75)
    missing = len(en_trans) - len(ru_trans)
    print(f"Russian stub: {len(ru_trans)}/{len(en_trans)} concepts ({missing} intentionally missing)")

    # Build dictionary.json
    dictionary = {
        "concepts": {cid: info for cid, info in concepts.items()},
        "groups": groups,
    }

    # Write output files
    os.makedirs(os.path.join(OUTPUT_DIR, "translations"), exist_ok=True)
    os.makedirs(os.path.join(OUTPUT_DIR, "tools", "sr"), exist_ok=True)

    files = {
        os.path.join(OUTPUT_DIR, "dictionary.json"): dictionary,
        os.path.join(OUTPUT_DIR, "translations", "en.json"): dict(en_trans),
        os.path.join(OUTPUT_DIR, "translations", "sr.json"): dict(sr_trans),
        os.path.join(OUTPUT_DIR, "translations", "ru.json"): dict(ru_trans),
        os.path.join(OUTPUT_DIR, "tools", "sr", "conjugations.json"): conjugations,
    }

    for path, content in files.items():
        rel = os.path.relpath(path, PROJECT_ROOT)
        print(f"Writing {rel}...")
        with open(path, "w", encoding="utf-8") as f:
            json.dump(content, f, ensure_ascii=False, indent=2)
            f.write("\n")

    # Summary
    print("\n=== MIGRATION SUMMARY ===")
    print(f"Concepts: {len(concepts)}")
    print(f"Groups: {len(groups)}")
    print(f"EN translations: {len(en_trans)}")
    print(f"SR translations: {len(sr_trans)}")
    print(f"RU translations: {len(ru_trans)} (stub)")
    print(f"Conjugation groups: {len(conjugations['groups'])}")

    # Validation
    print("\n=== VALIDATION ===")
    errors = 0
    for g in groups:
        for cid in g["concepts"]:
            if cid not in concepts:
                print(f"  ERROR: Concept '{cid}' in group '{g['id']}' not in concepts dict!")
                errors += 1
    for cid in concepts:
        if cid not in en_trans:
            print(f"  ERROR: Concept '{cid}' missing EN translation!")
            errors += 1
        if cid not in sr_trans:
            print(f"  ERROR: Concept '{cid}' missing SR translation!")
            errors += 1

    aspect_count = sum(1 for entries in sr_trans.values() if len(entries) > 1)
    print(f"Aspect pairs (concepts with 2+ SR translations): {aspect_count}")

    if errors == 0:
        print("All validations passed.")
    else:
        print(f"{errors} errors found!")

    print("\nDone.")


if __name__ == "__main__":
    main()
