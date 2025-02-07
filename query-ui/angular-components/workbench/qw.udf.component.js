/*
Copyright 2021-Present Couchbase, Inc.

Use of this software is governed by the Business Source License included in
the file licenses/BSL-Couchbase.txt.  As of the Change Date specified in that
file, in accordance with the Business Source License, use of this software will
be governed by the Apache License, Version 2.0, included in the file
licenses/APL2.txt.
*/

import {MnLifeCycleHooksToStream}  from 'mn.core';
import {Component,
  ViewEncapsulation,
  ChangeDetectorRef}               from '@angular/core';

import { NgbModal, NgbModalConfig }from '@ng-bootstrap/ng-bootstrap';

import { QwDialogService }         from '../../angular-directives/qw.dialog.service.js';
import { QwQueryWorkbenchService }          from '../../angular-services/qw.query.workbench.service.js';
import { QwMetadataService }       from "../../angular-services/qw.metadata.service.js";

import { QwFunctionDialog }        from '../../angular-components/workbench/dialogs/qw.function.dialog.component.js';
import { QwFunctionLibraryDialog } from '../../angular-components/workbench/dialogs/qw.function.library.dialog.component.js';

import template                    from "./qw.udf.html";

export {QwUdfComponent};


class QwUdfComponent extends MnLifeCycleHooksToStream {
  static get annotations() {
    return [
      new Component({
        template,
        selector: "qw-udf-component",
        styleUrls: ["../_p/ui/query/angular-directives/qw.directives.css"],
        encapsulation: ViewEncapsulation.None,
      })
    ]
  }

  static get parameters() {
    return [
      NgbModal,
      QwDialogService,
      QwMetadataService,
      QwQueryWorkbenchService,
    ];
  }

  ngOnInit() {
    this.qms.metaReady.then((val) =>
    {
      // update the UDF info if we have a valid service
      if (this.qms.valid()) {
        if (this.viewFunctionsPermitted())
          this.qqs.updateUDFs();
        if (this.externalPermitted())
          this.qqs.updateUDFlibs();
      }
    });
  }

  constructor(
    modalService,
    qwDialogService,
    qwMetadataService,
    qwQueryService) {
    super();

    this.qqs = qwQueryService;
    this.qds = qwDialogService;
    this.qms = qwMetadataService;
    this.modalService = modalService;

    this.function_sort = 'name';
    this.function_sort_direction = 1;

    this.lib_sort = 'namespace';
    this.lib_sort_direction = 1;

    this.rbac = qwMetadataService.rbac;
  }

  ngOnDestroy() {
  }

  // do we have permissions to view/manage external libraries?

  externalPermitted() {
    return(this.qms.isEnterprise() && this.rbac.init && (this.rbac.cluster.collection['.:.:.'].n1ql.udf_external.manage ||
      this.rbac.cluster.n1ql.udf_external.manage));
  }

  inlinePermitted() {
    return(this.rbac.cluster.collection['.:.:.'].n1ql.udf.manage ||
        this.rbac.cluster.n1ql.udf.manage);
  }

  viewFunctionsPermitted() {
    return(this.rbac.init && this.rbac.cluster.n1ql.meta.read);
  }

  manageFunctionsPermitted() {
    return(this.rbac.cluster.collection['.:.:.'].n1ql.udf.manage ||
        this.rbac.cluster.collection['.:.:.'].n1ql.udf_external.manage ||
        this.rbac.cluster.n1ql.udf.manage ||
        this.rbac.cluster.n1ql.udf_external.manage);
  }

  globalFunctionsPermitted() {
    return this.rbac.cluster.n1ql.udf.manage ||
        this.rbac.cluster.n1ql.udf_external.manage;
  }

  scopedFunctionsPermitted() {
    return(this.rbac.cluster.collection['.:.:.'].n1ql.udf.manage ||
        this.rbac.cluster.collection['.:.:.'].n1ql.udf_external.manage);
  }

  //
  // functions for handling table sorting
  //

  get_sorted_udfs() {
    let This = this;
    let udfs = this.qqs.udfs;
    // don't show functions we aren't allowed to manage
    if (!this.inlinePermitted())
      udfs = udfs.filter(fn => this.getFunctionLanguage(fn) != 'inline');
    if (!this.externalPermitted())
      udfs = udfs.filter(fn => this.getFunctionLanguage(fn) == 'inline');
    if (!this.globalFunctionsPermitted())
      udfs = udfs.filter(fn => fn.identity.bucket);
    if (!this.scopedFunctionsPermitted())
      udfs = udfs.filter(fn => !fn.identity.bucket);

    switch(this.function_sort) {
      case 'name':
        return udfs.sort((a,b) => a.identity.name.localeCompare(b.identity.name)*This.function_sort_direction);
      case 'scope':
        return udfs.sort((a,b) => ((a.identity.bucket || ' ') + (a.identity.scope || '') + a.identity.name)
          .localeCompare((b.identity.bucket || '')+(b.identity.scope || ' ') + b.identity.name)*This.function_sort_direction);
      case 'language':
        return udfs.sort((a,b) => (a.definition['#language']+a.identity.name)
            .localeCompare(b.definition['#language'] + b.identity.name)*This.function_sort_direction);
    }
    return udfs;
  }

  get_sorted_libs() {
    let This = this;
    let libs = this.qqs.udfLibs;
    // don't show libs we aren't allowed to manage
    if (!this.globalFunctionsPermitted())
      libs = libs.filter(lib => lib.bucket);
    if (!this.scopedFunctionsPermitted())
      libs = libs.filter(lib => !lib.bucket);

    switch(this.lib_sort) {
      case 'name':
        return libs.sort((a,b) => a.name.localeCompare(b.name)*This.lib_sort_direction);
      case 'namespace':
        return libs.sort((a,b) => ((a.bucket || '') + (a.scope || '') + a.name)
            .localeCompare((b.bucket || '')+(b.scope || '') + b.name)*This.lib_sort_direction);
    }
    return libs;
  }

  //
  // sorting for functions
  //

  update_function_sort(field) {
    if (this.function_sort == field)
      this.function_sort_direction *= -1;
    else {
      this.function_sort = field;
      this.function_sort_direction = 1;
    }
  }

  show_up_caret_function(field) {
    return(this.function_sort == field && this.function_sort_direction == -1);
  }

  show_down_caret_function(field) {
    return(this.function_sort == field && this.function_sort_direction == 1);
  }

  //
  // sorting for libraries
  //

  update_lib_sort(field) {
    if (this.lib_sort == field)
      this.lib_sort_direction *= -1;
    else {
      this.lib_sort = field;
      this.lib_sort_direction = 1;
    }
  }

  show_up_caret_lib(field) {
    return(this.lib_sort == field && this.lib_sort_direction == -1);
  }

  show_down_caret_lib(field) {
    return(this.lib_sort == field && this.lib_sort_direction == 1);
  }



  // get params for display in list

  getFunctionParams(fn) {
    if (!fn.definition.parameters)
      return('...')
    else
      return(JSON.stringify(fn.definition.parameters));
  }

  // inline functions are just 'inline', but javascript are: javascript (lib name)
  getFunctionLanguage(fn) {
    let result = fn.definition['#language'];
    if (fn.definition.library)
      result += ' (' + fn.definition.library + ')';
    return(result);
  }

  getFunctionScope(fn) {
    if (fn.identity.bucket)
      return(fn.identity.bucket + '.' + fn.identity.scope);
    else
      return("( global )");
  }

  // function edit/drop/create

  createFunction() {
    let This = this;
    this.dialogRef = this.modalService.open(QwFunctionDialog);
    this.dialogRef.componentInstance.header = "Add Function";
    this.dialogRef.componentInstance.name = "";
    this.dialogRef.componentInstance.bucket = null;
    this.dialogRef.componentInstance.function_type = this.inlinePermitted() ? 'inline_sql' : 'external_javascript';
    this.dialogRef.componentInstance.expression = "";
    this.dialogRef.componentInstance.parameters = ['...'];
    this.dialogRef.componentInstance.library_name = null;
    this.dialogRef.componentInstance.is_new = true;
    this.dialogRef.componentInstance.global_functions_permitted = this.globalFunctionsPermitted();
    this.dialogRef.componentInstance.scoped_functions_permitted = this.scopedFunctionsPermitted();
    this.dialogRef.componentInstance.inline_permitted = this.inlinePermitted();
    this.dialogRef.componentInstance.external_permitted = this.externalPermitted();

    this.dialogRef.result
      .then(function ok(new_value) {
        if (This.viewFunctionsPermitted())
          This.qqs.updateUDFs();
      }, function cancel() {});
  }

  editFunction(fn) {
    let This = this;
    this.dialogRef = this.modalService.open(QwFunctionDialog);
    this.dialogRef.componentInstance.header = this.manageFunctionsPermitted() ? "Edit Function" : "View Function";
    this.dialogRef.componentInstance.is_new = false;
    this.dialogRef.componentInstance.name = fn.identity.name;
    if (fn.identity.type == "scope") {
      this.dialogRef.componentInstance.bucket = fn.identity.bucket;
      this.dialogRef.componentInstance.scope = fn.identity.scope;
    }
    this.dialogRef.componentInstance.type = fn.definition['#language'];
    switch (fn.definition['#language']) {
      case 'javascript':
        if (fn.definition.library) {
          this.dialogRef.componentInstance.library_name = fn.definition.library;
          this.dialogRef.componentInstance.library_function = fn.definition.object;
          this.dialogRef.componentInstance.function_type = 'external_javascript';
        }
        else {
          this.dialogRef.componentInstance.expression = fn.definition.text;
          this.dialogRef.componentInstance.function_type = 'inline_javascript';
        }
        break;
      case 'inline':
        this.dialogRef.componentInstance.expression = fn.definition.text;
        this.dialogRef.componentInstance.function_type = 'inline_sql';
        break;
    }
    this.dialogRef.componentInstance.parameters = fn.definition.parameters || ['...'];
    this.dialogRef.componentInstance.readOnly = !this.manageFunctionsPermitted();
    this.dialogRef.componentInstance.global_functions_permitted = this.globalFunctionsPermitted();
    this.dialogRef.componentInstance.scoped_functions_permitted = this.scopedFunctionsPermitted();
    this.dialogRef.componentInstance.inline_permitted = this.inlinePermitted();
    this.dialogRef.componentInstance.external_permitted = this.externalPermitted();

    this.dialogRef.result
      .then(function ok(new_value) {
        This.qqs.updateUDFs();
      }, function cancel() {});
  }

  dropFunction(fn) {
    let This = this;
    let fnName = (fn.identity.bucket ? '`' + fn.identity.namespace + '`:`' + fn.identity.bucket + '`.`' +
        fn.identity.scope + '`.`' : '`') + fn.identity.name + '`';
    let fnUserVisibleName = (fn.identity.bucket ? fn.identity.bucket + '.' + fn.identity.scope + '.' : '') +
        fn.identity.name;
    this.qds.showNoticeDialog("Confirm Drop Function", "Warning, this function will be permanently removed: ",
      [fnUserVisibleName], "false")
      .then(function ok() {
        let query = 'DROP FUNCTION ' + fnName;
        This.qqs.executeQueryUtil(query, false)
          .then(function ok() {
              This.qqs.updateUDFs();
              This.qqs.updateUDFlibs();
            },
            function err(resp) {
              console.log("delete query: " + query);
              console.log("Got error deleting function: " + JSON.stringify(resp));
            });
      }, function cancel() {
      });
  }

  // library editor/drop/create

  createLibrary() {
    let This = this;
    this.dialogRef = this.modalService.open(QwFunctionLibraryDialog);
    this.dialogRef.componentInstance.header = "Add Library";
    this.dialogRef.componentInstance.new_lib = true;
    this.dialogRef.componentInstance.lib_name = '';
    this.dialogRef.componentInstance.bucket = null;
    this.dialogRef.componentInstance.scope = null;
    this.dialogRef.componentInstance.global_permitted = this.globalFunctionsPermitted();
    this.dialogRef.componentInstance.scoped_permitted = this.scopedFunctionsPermitted();
    this.dialogRef.componentInstance.lib_contents =
      '/* a UDF library contains one or more javascript functions */\n' +
      'function add(a,b) {\n' +
      '  return(a+b);\n' +
      '}\n';
    this.dialogRef.componentInstance.is_new = true;
    this.dialogRef.result
      .then(function ok() {}, function cancel(resp) {});
  }

  editLibrary(lib) {
    let This = this;
    this.dialogRef = this.modalService.open(QwFunctionLibraryDialog);
    this.dialogRef.componentInstance.header = "Edit Library";
    this.dialogRef.componentInstance.new_lib = false;
    this.dialogRef.componentInstance.lib_name = lib.name;
    this.dialogRef.componentInstance.bucket = lib.bucket;
    this.dialogRef.componentInstance.scope = lib.scope;
    this.dialogRef.componentInstance.lib_contents = lib.content;
    this.dialogRef.componentInstance.is_new = false;
    this.dialogRef.componentInstance.global_permitted = this.globalFunctionsPermitted();
    this.dialogRef.componentInstance.scoped_permitted = this.scopedFunctionsPermitted();
    this.dialogRef.result
      .then(function ok() {}, function cancel(resp) {});
  }

  dropLibrary(lib) {
    let libName = lib.name;
    if (lib.bucket && lib.scope && lib.bucket.length && lib.scope.length)
      libName = lib.bucket + '.' + lib.scope + '.' + lib.name;
    let This = this;
    this.qds.showNoticeDialog("Confirm Drop Function Library", "Warning, this javascript function library will be permanently removed:",
        [libName], "false")
      .then(function ok() {
        This.qqs.dropUDFlib(lib)
          .then(function success() {This.qqs.updateUDFlibs();},
            function err(resp) {This.qqs.updateUDFlibs();console.log("Error deleting library: " + JSON.stringify(resp))})
      }, function cancel() {
        console.log("cancel");
      });
  }

}
