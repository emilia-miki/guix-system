(define-module (packages noctalia-patched)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (guix gexp)
  #:use-module (noctalia)
  #:export (noctalia-patched))

;; noctalia-git with a patch that adds `names = [...]` support to the
;; workspaces widget.  When set, the list is indexed by the tag's 1-based
;; numeric ID and the matching string is shown instead of the number.
(define-public noctalia-patched
  (package
    (inherit noctalia-git)
    (name "noctalia-patched")
    (arguments
     (substitute-keyword-arguments (package-arguments noctalia-git)
       ((#:phases phases)
        #~(modify-phases #$phases
            (add-after 'prepare-for-build 'add-workspace-names
              (lambda _
                ;; substitute* processes files line-by-line, so all patterns
                ;; must match within a single line; replacements may contain \n.

                ;; 1. workspaces_widget.h — constructor param + field declaration
                (substitute* "src/shell/bar/widgets/workspaces_widget.h"
                  ;; 6-space indent distinguishes this from the .cpp definition (4-space)
                  (("      bool hideWhenEmpty, float pillScale, float activePillSize, float inactivePillSize, bool minimal")
                   "      bool hideWhenEmpty, float pillScale, float activePillSize, float inactivePillSize, bool minimal,\n      std::vector<std::string> names = {}")
                  (("  bool m_minimal = false;")
                   "  bool m_minimal = false;\n  std::vector<std::string> m_names;"))

                ;; 2. workspaces_widget.cpp — constructor definition + label function
                (substitute* "src/shell/bar/widgets/workspaces_widget.cpp"
                  ;; 4-space indent, no trailing semicolon — unique to the .cpp definition
                  (("    bool hideWhenEmpty, float pillScale, float activePillSize, float inactivePillSize, bool minimal")
                   "    bool hideWhenEmpty, float pillScale, float activePillSize, float inactivePillSize, bool minimal,\n    std::vector<std::string> names")
                  ;; Add m_names to the initializer list
                  (("m_inactivePillSize\\(std::clamp\\(inactivePillSize, 0\\.25f, 8\\.0f\\)\\), m_minimal\\(minimal\\), m_focusedColor")
                   "m_inactivePillSize(std::clamp(inactivePillSize, 0.25f, 8.0f)), m_minimal(minimal),\n      m_names(std::move(names)), m_focusedColor")
                  ;; Prepend the custom-names check to workspaceLabel
                  (("std::string WorkspacesWidget::workspaceLabel\\(const Workspace& workspace, std::size_t displayIndex\\) const \\{")
                   "std::string WorkspacesWidget::workspaceLabel(const Workspace& workspace, std::size_t displayIndex) const {\n  if (!m_names.empty() && workspace.index > 0 && workspace.index <= m_names.size()) {\n    return m_names[workspace.index - 1];\n  }"))

                ;; 3. widget_factory.cpp — read `names` key and pass to constructor
                (substitute* "src/shell/bar/widget_factory.cpp"
                  (("    const bool minimal = wc != nullptr \\? wc->getBool\\(\"minimal\", false\\) : false;")
                   "    const bool minimal = wc != nullptr ? wc->getBool(\"minimal\", false) : false;\n    const std::vector<std::string> names =\n        wc != nullptr ? wc->getStringList(\"names\") : std::vector<std::string>{};")
                  (("        hideWhenEmpty, pillScale, static_cast<float>\\(activePillSize\\), static_cast<float>\\(inactivePillSize\\), minimal")
                   "        hideWhenEmpty, pillScale, static_cast<float>(activePillSize), static_cast<float>(inactivePillSize), minimal, names"))))))))))
