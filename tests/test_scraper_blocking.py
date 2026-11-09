import io
import os
import unittest
from unittest.mock import patch
from urllib.error import HTTPError

import importlib.util

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
spec = importlib.util.spec_from_file_location(
    "DataScrapper", os.path.join(ROOT, "script", "DataScrapper.py")
)
ds = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ds)

PRODUCT_HTML = """
<html><body>
  <div class="product">
    <div class="name">Test Mustard Oil</div>
    <div class="subText">1 ltr</div>
    <div class="price">৳355</div>
  </div>
</body></html>
"""


class FetchBlockingTests(unittest.TestCase):
    def test_static_request_uses_full_browser_user_agent(self):
        captured = {}

        class Response:
            def getcode(self):
                return 200

            def read(self):
                return PRODUCT_HTML.encode("utf-8")

        def fake_urlopen(req, *args, **kwargs):
            captured["ua"] = req.get_header("User-agent")
            return Response()

        with patch.object(ds, "urlopen", fake_urlopen):
            status, html = ds._fetch_html("https://chaldal.com/oil")

        self.assertEqual(status, 200)
        self.assertIn("Test Mustard Oil", html)
        self.assertNotEqual(captured["ua"], "Mozilla/5.0")
        self.assertIn("Chrome/", captured["ua"])

    def test_cloudflare_403_still_tries_rendered_html(self):
        def fake_urlopen(req, *args, **kwargs):
            raise HTTPError(
                "https://chaldal.com/oil",
                403,
                "Forbidden",
                hdrs=None,
                fp=io.BytesIO(b"Just a moment"),
            )

        rendered_calls = []

        def fake_render(url, log_data):
            rendered_calls.append(url)
            return PRODUCT_HTML

        logs = []
        with patch.object(ds, "urlopen", fake_urlopen), \
                patch.object(ds, "_fetch_rendered_html", fake_render), \
                patch.object(ds, "write_log", lambda lines: logs.extend(lines)):
            rows, should_retry = ds.get_product_data("https://chaldal.com/oil", "oil")

        self.assertEqual(rendered_calls, ["https://chaldal.com/oil"])
        self.assertEqual(len(rows), 1)
        self.assertEqual(rows[0][0], "Test Mustard Oil")
        self.assertEqual(rows[0][5], "355")
        self.assertFalse(should_retry)
        self.assertTrue(any("403" in line for line in logs))
        self.assertTrue(any("Data rows for oil: 1" in line for line in logs))


if __name__ == "__main__":
    unittest.main()
