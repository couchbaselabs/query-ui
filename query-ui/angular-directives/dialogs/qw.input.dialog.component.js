import {MnLifeCycleHooksToStream}     from 'mn.core';
import {NgbActiveModal}               from '@ng-bootstrap/ng-bootstrap';
import {Component, ViewEncapsulation} from '@angular/core';
import { CommonModule }               from '@angular/common';

export { QwInputDialog };

class QwInputDialog extends MnLifeCycleHooksToStream {
  static get annotations() {
    return [
    new Component({
      templateUrl: new URL("./qw.input.dialog.html", import.meta.url).pathname,
      styleUrls: ["../_p/ui/query/angular-directives/qw.directives.css"],
      imports: [ CommonModule ],
      inputs: ["header_message", "body_message", "input_value"],
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

    if (!this.input_value)
      this.input_value = '';
  }

}
