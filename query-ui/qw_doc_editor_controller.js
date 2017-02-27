/**
 * A controller for managing a document editor based on queries
 */

(function() {


  angular.module('qwQuery').controller('qwDocEditorController', docEditorController);

  docEditorController.$inject = ['$rootScope', '$scope', '$uibModal', '$timeout', 'qwQueryService', 'validateQueryService'];

  function docEditorController ($rootScope, $scope, $uibModal, $timeout, qwQueryService, validateQueryService) {

    var dec = this;

    //
    // Do we have a REST API to work with?
    //

    dec.validated = validateQueryService;

    //
    // for persistence, keep some options in the query_service
    //

    dec.options = qwQueryService.doc_editor_options;
    dec.currentDocs = [];
    dec.buckets = qwQueryService.bucket_names;

    //
    //
    //

    dec.retrieveDocs = retrieveDocs;
    dec.nextBatch = nextBatch;
    dec.prevBatch = prevBatch;

    dec.clickedOn = function(row) {console.log("clicked on: " + row);};
    dec.updateDoc = updateDoc;

    dec.updatingRow = -1;

    //
    // call the activate method for initialization
    //

    activate();

    //
    // get the next or previous set of documents using paging
    //

    function prevBatch() {
      dec.options.offset -= dec.options.limit;
      if (dec.options.offset < 0)
        dec.options.offset = 0;
      retrieveDocs();
    }

    function nextBatch() {
      dec.options.offset += dec.options.limit;
      retrieveDocs();
    }

    //
    // function to update a document given what the user typed
    //

    function updateDoc(row, makePristine) {
      if (dec.updatingRow >= 0)
        return;

      dec.updatingRow = row;

      console.log("updating row: " + row);
      var query = "UPSERT INTO `" + dec.options.current_bucket + '` (KEY, VALUE) VALUES ("' +
        dec.options.current_result[row].id + '", ' +
        JSON.stringify(dec.options.current_result[row].data) + ')';
      //console.log("Query: " + query + ", pristine: " + makePristine);

      qwQueryService.executeQueryUtil(query,false)
      // did the query succeed?
      .success(function(data, status, headers, config) {
        console.log("successfully updated row: " + row);
        makePristine();
        dec.updatingRow = -1;
      })

      // ...or fail?
      .error(function (data,status,headers,config) {
        console.log("failed updating row: " + row);
        dec.updatingRow = -1;
      });

    }

    //
    // function to save a document with a different key
    //

    function saveDocAs(row) {
      if (dec.updatingRow >= 0)
        return;

      dec.updatingRow = row;

      // bring up a dialog to get the new key

      var dialogScope = $rootScope.$new(true);

      // default names for save and save_query
      dialogScope.data = {value: dec.options.current_result[row].id + '_copy'};
      dialogScope.header_message = "Save As...";
      dialogScope.body_message = "Enter a key for the new document: ";

      $uibModal.open({
        templateUrl: '../_p/ui/query/ui/current/file_dialog/qw_input_dialog.html',
        scope: dialogScope
      }).then(function (res) {

        //console.log("Promise, file: " + tempScope.file.name + ", res: " + res);
        console.log("saving row: " + row);
        var query = "INSERT INTO `" + dec.options.current_bucket + '` (KEY, VALUE) VALUES ("' +
          dialogScope.data.value + '", ' +
          JSON.stringify(dec.options.current_result[row].data) + ')';
        //console.log("Query: " + query + ", pristine: " + makePristine);

        qwQueryService.executeQueryUtil(query,false)
        // did the query succeed?
        .success(function(data, status, headers, config) {
          console.log("successfully updated row: " + row);
          makePristine();
          dec.updatingRow = -1;
        })

        // ...or fail?
        .error(function (data,status,headers,config) {
          console.log("failed updating row: " + row);
          dec.updatingRow = -1;
        });


      });


    }

    //
    // function to delete a document
    //

    function deleteDoc(row) {
      if (dec.updatingRow >= 0)
        return;

      dec.updatingRow = row;

      console.log("deleting row: " + row);
      var query = "DELETE FROM `" + dec.options.current_bucket + '` USE KEYS "' +
        dec.options.current_result[row].id;

      qwQueryService.executeQueryUtil(query,false)
      // did the query succeed?
      .success(function(data, status, headers, config) {
        console.log("successfully deleted row: " + row);
        makePristine();
        dec.updatingRow = -1;
      })

      // ...or fail?
      .error(function (data,status,headers,config) {
        console.log("failed deleting row: " + row);
        dec.updatingRow = -1;
      });

    }

    //
    // build a query from the current options, and get the results
    //

    function retrieveDocs() {
      //console.log("Retrieving docs...");
      qwQueryService.saveStateToStorage();

      // create a query based on either limit/skip or where clause

      // can't do anything without a bucket
      if (!dec.options.selected_bucket || dec.options.selected_bucket.length == 0)
        return;

      // start making a query
      var query = 'select meta().id, * from `' + dec.options.selected_bucket +
        '` data ';

      if (dec.options.where_clause && dec.options.where_clause.length > 0)
        query += 'where ' + dec.options.where_clause;

      if (dec.options.limit && dec.options.limit > 0) {
        query += ' limit ' + dec.options.limit + ' offset ' + dec.options.offset;
      }

      dec.options.current_query = query;
      dec.options.current_bucket = dec.options.selected_bucket;
      dec.options.current_result = [];

      qwQueryService.executeQueryUtil(query,false)

      // did the query succeed?
      .success(function(data, status, headers, config) {
        //console.log("Editor Q Success Data Len: " + JSON.stringify(data.results.length));
        //console.log("Editor Q Success Status: " + JSON.stringify(status));

        if (data && data.status && data.status == 'success')
          dec.options.current_result = data.results;
      })

      // ...or fail?
      .error(function (data,status,headers,config) {
        //console.log("Editor Q Error Data: " + JSON.stringify(data));
        //console.log("Editor Q Error Status: " + JSON.stringify(status));

        if (data && data.errors) {
          dec.options.current_result = JSON.stringify(data.errors);
          console.log("Got error: " + dec.options.current_result);
        }
      });

    }

    //
    //
    //

    function activate() {
    }

    //
    // all done, return the controller
    //

    return dec;
  }


})();