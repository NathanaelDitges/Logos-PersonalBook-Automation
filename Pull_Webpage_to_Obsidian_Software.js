javascript:(function () {
  Promise.all([
    import("https://unpkg.com/turndown@6.0.0?module"),
    import("https://unpkg.com/@tehshrike/readability@0.2.0"),
  ]).then(async ([{ default: Turndown }, { default: Readability }]) => {
    /* Optional vault name */
    const vault = "";

    /* Optional folder name such as "Clippings/" */
    const folder = "";

    /* Optional tags */
    const tags = "#clippings";

    function getSelectionHtml() {
      let html = "";

      if (typeof window.getSelection !== "undefined") {
        const sel = window.getSelection();

        if (sel.rangeCount) {
          const container = document.createElement("div");

          for (let i = 0, len = sel.rangeCount; i < len; ++i) {
            container.appendChild(sel.getRangeAt(i).cloneContents());
          }

          html = container.innerHTML;
        }
      } else if (typeof document.selection !== "undefined") {
        if (document.selection.type === "Text") {
          html = document.selection.createRange().htmlText;
        }
      }

      return html;
    }

    const selection = getSelectionHtml();

    const { title, byline, content } = new Readability(
      document.cloneNode(true)
    ).parse();

    function getFileName(fileName) {
      const platform = window.navigator.platform;
      const windowsPlatforms = ["Win32", "Win64", "Windows", "WinCE"];

      if (windowsPlatforms.indexOf(platform) !== -1) {
        fileName = fileName
          .replace(":", "")
          .replace(/[\/\\?%*|"<>]/g, "-");
      } else {
        fileName = fileName
          .replace(":", "")
          .replace(/\//g, "-")
          .replace(/\\/g, "-");
      }

      return fileName;
    }

    const fileName = getFileName(title);

    let markdownify;
    if (selection) {
      markdownify = selection;
    } else {
      markdownify = content;
    }

    let vaultName;
    if (vault) {
      vaultName = "&vault=" + encodeURIComponent(`${vault}`);
    } else {
      vaultName = "";
    }

    const markdownBody = new Turndown({
      headingStyle: "atx",
      hr: "---",
      bulletListMarker: "-",
      codeBlockStyle: "fenced",
      emDelimiter: "*",
    }).turndown(markdownify);

    const date = new Date();

    function convertDate(date) {
      const yyyy = date.getFullYear().toString();
      const mm = (date.getMonth() + 1).toString();
      const dd = date.getDate().toString();

      const mmChars = mm.split("");
      const ddChars = dd.split("");

      return (
        yyyy +
        "-" +
        (mmChars[1] ? mm : "0" + mmChars[0]) +
        "-" +
        (ddChars[1] ? dd : "0" + ddChars[0])
      );
    }

    const today = convertDate(date);

    const fileContent =
      "author:: " +
      byline +
      "\n" +
      "source:: [" +
      title +
      "](" +
      document.URL +
      ")\n" +
      "clipped:: [[" +
      today +
      "]]\n" +
      "published:: \n\n" +
      tags +
      "\n\n" +
      markdownBody;

    document.location.href =
      "obsidian://new?" +
      "file=" +
      encodeURIComponent(folder + fileName) +
      "&content=" +
      encodeURIComponent(fileContent) +
      vaultName;
  });
})();
