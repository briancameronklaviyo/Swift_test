"""
Validate XML product feeds using the same field rules as the JSON validator.
Expects an XML root containing a list of product elements (e.g. <products><product>...</product></products>).
"""
import xml.etree.ElementTree as ET
from pathlib import Path

# --- set your local file path here ---
xml_path = Path.home() / "Downloads" / "KlaviyoUS (2).xml"


def strip_namespace(tag: str) -> str:
    """Return tag without namespace, e.g. '{http://...}product' -> 'product'."""
    if tag.startswith("{"):
        return tag.split("}", 1)[1]
    return tag


def element_to_row(element: ET.Element) -> dict:
    """
    Convert an XML element to a flat dict: child tag name (no namespace) -> text content.
    Uses first direct child only for repeated tags; strips whitespace from text.
    """
    row = {}
    for child in element:
        key = strip_namespace(child.tag)
        # Prefer direct text; for elements with nested structure, join all text
        text = (child.text or "").strip()
        if not text and len(child):
            text = " ".join(child.itertext()).strip()
        if key:
            row[key] = text
    # Also include attributes as keys (e.g. id="123" -> row["id"] = "123")
    for name, value in element.attrib.items():
        row[strip_namespace(name)] = (value or "").strip()
    return row


def load_xml(path: Path) -> ET.Element:
    if not path.exists():
        raise FileNotFoundError(f"XML file not found: {path}")
    with path.open("rb") as f:
        tree = ET.parse(f)
    return tree.getroot()


# --- FIELD MAP: canonical field -> allowed aliases in the feed (same as JSON validator) ---
FIELD_MAP = {
    "id": {"$id", "id", "SKU"},
    "title": {"$title", "title", "ProductName"},
    "description": {"$description", "description"},
    "link": {"$link", "link", "ProductLink"},
    "image_link": {"$image_link", "image_link", "ImageUrl"},
}


def row_is_valid(row: dict) -> bool:
    for _, aliases in FIELD_MAP.items():
        if not any(alias in row for alias in aliases):
            return False
    return True


def missing_fields(row: dict) -> dict:
    """Return canonical_field -> accepted aliases for fields that are missing."""
    missing = {}
    for canonical, aliases in FIELD_MAP.items():
        if not any(alias in row for alias in aliases):
            missing[canonical] = sorted(aliases)
    return missing


# --- Config: name of the repeating product element (change if your XML uses another tag) ---
PRODUCT_TAG = "product"  # or "item", "entry", etc.


def get_product_elements(root: ET.Element) -> list[ET.Element]:
    """
    Get list of product elements. Handles:
    - Root is already the list container: <products><product>...</product></products>
    - Root is the container itself with product children
    """
    # If root's tag looks like a container, use its children
    root_tag = strip_namespace(root.tag)
    if root_tag in ("products", "items", "feed", "channel", "catalog", "root"):
        return [el for el in root if strip_namespace(el.tag) == PRODUCT_TAG]
    # If root is the single product wrapper, treat root as the only item
    if root_tag == PRODUCT_TAG:
        return [root]
    # Otherwise assume direct children are products (e.g. <feed><product/><product/></feed>)
    return [el for el in root if strip_namespace(el.tag) == PRODUCT_TAG]


def main():
    print(f"Validating: {xml_path}", flush=True)
    if not xml_path.exists():
        print(f"ERROR: File not found: {xml_path}", flush=True)
        return

    root = load_xml(xml_path)
    product_elements = get_product_elements(root)

    print(f"Root tag: '{strip_namespace(root.tag)}', found {len(product_elements)} <{PRODUCT_TAG}> element(s)", flush=True)

    if not product_elements:
        print(
            f"ERROR: No <{PRODUCT_TAG}> elements found. "
            f"Root has {len(root)} children (tags: {[strip_namespace(c.tag) for c in list(root)[:10]]}). "
            f"If your product tag is different, set PRODUCT_TAG at the top of the script.",
            flush=True,
        )
        return

    count = 0
    bad_count = 0
    bad_examples_printed = 0
    MAX_BAD_EXAMPLES = 5

    for i, el in enumerate(product_elements, start=1):
        row = element_to_row(el)
        if row_is_valid(row):
            count += 1
        else:
            bad_count += 1
            if bad_examples_printed < MAX_BAD_EXAMPLES:
                missing = missing_fields(row)
                print(f"\nRow #{i} (element <{el.tag}>) is missing required fields:")
                for canonical, aliases in missing.items():
                    print(f"  - {canonical}: expected one of {aliases}")
                print(f"  Present keys: {sorted(row.keys())[:30]}{'...' if len(row) > 30 else ''}")
                bad_examples_printed += 1

    print(f"\ngood rows {count}", flush=True)
    print(f"bad rows {bad_count}", flush=True)
    print(f"total products: {count + bad_count}", flush=True)


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"ERROR: {e}", flush=True)
        raise
