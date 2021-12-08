import {MnLifeCycleHooksToStream}     from 'mn.core';
import {NgbActiveModal}               from '@ng-bootstrap/ng-bootstrap';
import {Component, ViewEncapsulation} from '@angular/core';
import { CommonModule }               from '@angular/common';

export { QwFunctionLibraryDialog };

class QwFunctionLibraryDialog extends MnLifeCycleHooksToStream {
  static get annotations() {
    return [
    new Component({
      templateUrl: "../_p/ui/query/angular-components/workbench/dialogs/qw.function.library.dialog.html",
      styleUrls: ["../_p/ui/query/angular-directives/qw.directives.css"],
      imports: [ CommonModule ],
      inputs: ["header", "lib_name","lib_contents", "new_lib"],
      encapsulation: ViewEncapsulation.None,
    })
  ]}

  static get parameters() {
    return [
      NgbActiveModal,
      ];
  }

  ngOnInit() {
  }

  constructor(activeModal) {
    super();

    this.activeModal = activeModal;
    this.config = ace.require("ace/config" );

    // unbind ^F for all ACE editors
    var default_commands = ace.require("ace/commands/default_commands");
    for (var i=0; i< default_commands.commands.length; i++)
      if (default_commands.commands[i].name.startsWith("find")) {
        default_commands.commands.splice(i,1);
        i--;
      }
  }

  searchDoc() {
    var This = this;
    this.config.loadModule("ace/ext/cb-searchbox",
        function(e) {
          if (This.mainEditor) e.Search(This.mainEditor,true,true);
        });

  }

  errors() {
    // don't allow empty doc id
    if (!this.lib_name)
      return true;

    return false;
  }

  onMainEditorReady(editor) {
    var This = this;
    this.mainEditor = editor;
    editor.$blockScrolling = Infinity;
    editor.renderer.setPrintMarginColumn(false); // hide page boundary lines
    editor.setReadOnly(this.readonly);

    // disable syntax checking, since non-standard javascript in use
    editor.getSession().setUseWorker(false);
    if (/^((?!chrome).)*safari/i.test(navigator.userAgent))
      editor.renderer.scrollBarV.width = 20; // fix for missing scrollbars in Safari

    editor.setOptions({
      mode: 'ace/mode/javascript',
      showGutter: true,
      wrap: true,
    });
  }

}
