Yes. The current limitation is that the implementation is not yet parsing PDF annotations or true hyperlink objects in a native way.

Right now it works by scanning the PDF file bytes for URL-like text patterns such as http:// or https://. That means it can find links when they appear as plain text inside the document content, but it does not yet reliably identify:
- actual PDF annotation links,
- clickable hyperlink objects embedded in the PDF structure,
- more complex cases where the URL is stored in a form that is not easy to detect from raw text.

In practice, that means:
- it is good as a first-pass link inventory and basic replacement tool,
- but it may miss some links or produce false positives on documents that contain URLs in other contexts.

So the limitation is not in the UI or CSV export flow; it is in the PDF parsing depth. The next step would be to move from raw-text scanning to more structured PDF parsing so the tool can work with real hyperlink annotations and be much more reliable on production PDFs.