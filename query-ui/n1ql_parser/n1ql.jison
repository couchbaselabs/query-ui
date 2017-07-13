%{
  // to make this grammar similar to the golang N1QL grammar, we need to implement some of the convenience functions
  // in golang that are used in the parser productions.
  
  function expr(type,ex) {
    this.type = type;
    this.ops = {};
    //console.log("Creating expression type: " + type + (ex ? (" (" + ex + ")") : ""));
  }

  expr.prototype.Alias = function() {return this.ops.name;};
  expr.prototype.Select = function() {return this.ops.select;};
  expr.prototype.Subquery = function() {return this.ops.subquery;};
  expr.prototype.Keys = function() {return this.ops.keys;};
  expr.prototype.Indexes = function() {return this.ops.indexes;};

  var expression = {};
  expression.Bindings = [];
  expression.Expressions = [];
  expression.FALSE_EXPR = "FALSE";
  expression.MISSING_EXPR = "MISSING";
  expression.NULL_EXPR = "NULL";
  expression.TRUE_EXPR = "TRUE";
  
  expression.NewAdd = function(first, second)                     {var e = new expr("Add"); e.ops.first = first; e.ops.second = second; return e;};
  expression.NewAll = function(all_expr, distinct)                {var e = new expr("All"); e.ops.all_expr = all_expr; return e;};
  expression.NewAnd = function(first, second)                     {var e = new expr("And"); e.ops.first = first; e.ops.second = second; return e;};
  expression.NewAny = function(bindings, satisfies)               {var e = new expr("Any"); e.ops.bindings = bindings; e.ops.satisfies = satisfies; return e;};
  expression.NewAnyEvery = function(bindings, satisfies)          {var e = new expr("AnyEvery"); e.ops.bindings = bindings; e.ops.satisfies = satisfies;return e;};
  expression.NewArray = function(mapping, bindings, when)         {var e = new expr("Array"); e.ops.mapping = mapping; e.ops.bindings = bindings; e.ops.when = when; return e;};
  expression.NewArrayConstruct = function(elements)               {var e = new expr("ArrayConstruct"); e.ops.elements = elements; return e;};
  expression.NewArrayStar = function(operand)                     {var e = new expr("ArrayStar"); e.ops.operand = operand; return e;};
  expression.NewBetween = function(item, low, high)               {var e = new expr("Between"); e.ops.item = item; e.ops.low = low; e.ops.high = high; return e;};
  expression.NewBinding = function(name_variable, variable, binding_expr, descend)
  			  			  	          {var e = new expr("Binding"); e.ops.name_variable = name_variable; e.ops.variable = variable; e.ops.binding_expr = binding_expr; e.ops.descend = descend; return e;};
  expression.NewConcat = function(first, second)                  {var e = new expr("Concat"); e.ops.first = first; e.ops.second = second; return e;};
  expression.NewConstant = function(value)                        {var e = new expr("Constant"); e.ops.value = value; return e;};
  expression.NewCover = function(covered)                         {var e = new expr("Cover"); e.ops.covered = covered; return e;};
  expression.NewDiv = function(first, second)                     {var e = new expr("Div"); e.ops.first = first; e.ops.second = second; return e;};
  expression.NewElement = function(first, second)                 {var e = new expr("Element"); e.ops.first = first; e.ops.second = second; return e;};
  expression.NewEq = function(first, second)                      {var e = new expr("Eq"); e.ops.first = first; e.ops.second = second; return e;};
  expression.NewEmpty = function()                                {var e = new expr("Empty"); return e;};
  expression.NewEvery = function(bindings, satisfies)             {var e = new expr("Every"); e.ops.bindings = bindings; e.ops.satisfies = satisfies; return e;};
  expression.NewExists = function(operand)                        {var e = new expr("Exists"); e.ops.operand = operand; return e;};
  expression.NewField = function(first,second)                    {var e = new expr("Field"); e.ops.first = first; e.ops.second = second; return e;};
  expression.NewFieldName = function(field_name,case_insensitive) {var e = new expr("FieldName",field_name); e.ops.field_name = field_name; e.ops.case_insensitive = case_insensitive; return e;};
  expression.NewFirst = function(expression,coll_bindings,when)   {var e = new expr("Field"); e.ops.expression = expression; e.ops.coll_bindings = coll_bindings; e.ops.when = when; return e;};
  expression.NewGE = function(first, second)                      {var e = new expr("GE"); e.ops.first = first; e.ops.second = second; return e;};
  expression.NewGT = function(first, second) 			  {var e = new expr("GT"); e.ops.first = first; e.ops.second = second; return e;};
  expression.NewIdentifier = function(identifier) 		  {var e = new expr("Identifier",identifier); e.ops.identifier = identifier; return e;};
  expression.NewIn = function(first, second) 			  {var e = new expr("In"); e.ops.first = first; e.ops.second = second; return e;};
  expression.NewIsMissing = function(operand) 			  {var e = new expr("IsMissing"); e.ops.operand = operand; return e;};
  expression.NewIsNotNull = function(operand) 			  {var e = new expr("IsNotNull"); e.ops.operand = operand; return e;};
  expression.NewIsNotMissing = function(operand) 		  {var e = new expr("IsNotMissing"); e.ops.operand = operand; return e;};
  expression.NewIsNotValued = function(operand) 		  {var e = new expr("IsNotValued"); e.ops.operand = operand; return e;};
  expression.NewIsNull = function(operand) 			  {var e = new expr("IsNull"); e.ops.operand = operand; return e;};
  expression.NewIsValued = function(operand) 			  {var e = new expr("IsValued"); e.ops.operand = operand; return e;};
  expression.NewLE = function(first, second) 			  {var e = new expr("LE"); e.ops.first = first; e.ops.second = second; return e;};
  expression.NewLT = function(first, second) 			  {var e = new expr("LT"); e.ops.first = first; e.ops.second = second; return e;};
  expression.NewLike = function(first, second) 			  {var e = new expr("Like"); e.ops.first = first; e.ops.second = second; return e;};
  expression.NewMod = function(first, second) 			  {var e = new expr("Mod"); e.ops.first = first; e.ops.second = second; return e;};
  expression.NewMult = function(first, second) 			  {var e = new expr("Multi"); e.ops.first = first; e.ops.second = second; return e;};
  expression.NewNE = function(first, second) 			  {var e = new expr("NE"); e.ops.first = first; e.ops.second = second; return e;};
  expression.NewNeg = function(operand) 			  {var e = new expr("Neg"); e.ops.operand = operand; return e;};
  expression.NewNot = function(operand) 			  {var e = new expr("Not"); e.ops.operand = operand; return e;};
  expression.NewNotBetween = function(iteem, low, high) 	  {var e = new expr("NotBetween"); e.ops.item = item; e.ops.low = low; e.ops.high = high; return e;};
  expression.NewNotIn = function(first, second)   		  {var e = new expr("NotIn"); e.ops.first = first; e.ops.second = second; return e;};
  expression.NewNotLike = function(first, second) 		  {var e = new expr("NotLike"); e.ops.first = first; e.ops.second = second; return e;};
  expression.NewNotWithin = function(first, second) 		  {var e = new expr("NotWithin"); e.ops.first = first; e.ops.second = second; return e;};
  expression.NewObject = function(name_mapping, value_mapping, bindings, when)
  		       	 				          {var e = new expr("Object"); e.ops.name_mapping = name_mapping; e.ops.value_mapping = value_mapping; e.ops.bindings = bindings; e.ops.when = when; return e;};
  expression.NewObjectConstruct = function(mapping)               {var e = new expr("ObjectConstruct"); e.ops.mapping = mapping; return e;};
  expression.NewOr = function(first, second)                      {var e = new expr("Or"); e.ops.first = first; e.ops.second = second; return e;};
  expression.NewSearchedCase = function(when_terms, else_term) 	  {var e = new expr("SearchedCase"); e.ops.when_terms = when_terms; e.ops.else_term = else_term; return e;};
  expression.NewSelf = function() 		   		  {var e = new expr("Self"); return e;};
  expression.NewSimpleBinding = function(variable, binding_expr)  {var e = new expr("SimpleBinding"); e.ops.variable = variable; e.ops.binding_expr = binding_expr; return e;};
  expression.NewSimpleCase = function(search_term, when_terms, else_term)
  			     			   	          {var e = new expr("SimpleCase"); e.ops.search_term = search_term; e.ops.when_terms = when_term; e.ops.else_term = else_term; return e;};
  expression.NewSlice = function(first, second, third)            {var e = new expr("Slice"); e.ops.first = first; e.ops.second = second; e.ops.third = third; return e;};
  expression.NewFunction = function(fname, param_expr, distinct)  {var e = new expr("Function"); e.ops.fname = fname; e.ops.param_expr = param_expr; e.ops.distinct = distinct; return e;};
  expression.NewSub = function(first, second) 	       		  {var e = new expr("Sub"); e.ops.first = first; e.ops.second = second; return e;};
  expression.NewWithin = function(first, second) 		  {var e = new expr("Within"); e.ops.first = first; e.ops.second = second; return e;};

  //

  var algebra = {};
  algebra.EMPTY_USE = new expr("EMPTY_USE");
  algebra.MapPairs = function(pairs)                                       {var a = new expr("Pairs"); a.ops.pairs = pairs; return a;}
  algebra.NewAlterIndex = function(keyspace, index_name, opt_using, rename){var a = new expr("AlterIndex"); a.ops.keyspace = keyspace; a.ops.index_name = index_name; a.ops.opt_using = opt_using; a.ops.rename = rename; return a;};
  algebra.NewBuildIndexes = function(keyspace,opt_index,index_names)       {var a = new expr("BuildIndexes"); a.ops.keyspace = keyspace; a.opt_index = opt_index; a.ops.index_names = index_names; return a;};
  algebra.NewCreateIndex = function(index_name,keyspace,index_terms,index_partition,index_where,index_using,index_with) {var a = new expr("CreateIndex"); a.ops.index_name = index_name; a.ops.keyspace = keyspace; a.ops.index_terms - index_terms; a.ops.index_partition = index-partition; a.ops.index_where = index_where; a.ops.index_using = index_using; a.ops.index_where = index_where; return a;};
  algebra.NewCreatePrimaryIndex = function(opt_name,keyspace,index_using,index_with) {var a = new expr("CreatePrimateIndex"); a.ops.opt_name = opt_name; a.ops.keyspace = keyspace; a.ops.index_using = index_using; a.ops.index_with = index_with; return a;};
  algebra.NewDelete = function(keyspace,opt_use_keys,opt_use_indexes,opt_where,opt_limit,opt_returning) {var a = new expr("Delete"); a.ops.keyspace = keyspace; a.ops.opt_use_keys = opt_use_keys; a.ops.opt_use_indexes = opt_use_indexes; a.ops.opt_where = opt_where; a.ops.opt_limit = opt_limit; return a;};
  algebra.NewDropIndex = function(keyspace, opt_using)                     {var a = new expr("DropIndex"); a.ops.keyspace = keyspace; a.ops.opt_using = opt_using; return a;};
  algebra.NewExcept = function(first,except)                               {var a = new expr("Except"); a.ops.first = first; a.ops.except = except; return a;};
  algebra.NewExceptAll = function(first,except)                            {var a = new expr("ExceptAll"); a.ops.first = first; a.ops.except = except; return a;};
  algebra.NewExecute = function(expression)                                {var a = new expr("Execute"); a.ops.expression = expression; return a;};
  algebra.NewExplain = function(statement)                                 {var a = new expr("Explain"); a.ops.statement = statement; return a;};
  algebra.NewExpressionTerm = function(expression, opt_as_alias, opt_use)  {var a = new expr("ExpressionTerm"); a.ops.expression = expression; a.ops.opt_as_alias = opt_as_alias; a.ops.opt_use = opt_use; return a;};
  algebra.NewGrantRole = function(role_list,user_list,keyspace_list)       {var a = new expr("GrantRole"); a.ops.role_list = role_list; a.ops.user_list = user_list; a.ops.keyspace_list = keyspace_list; return a;};
  algebra.NewGroup = function(expression,opt_letting,opt_having)           {var a = new expr("Group"); a.ops.expression = expression; a.ops.opt_letting = opt_letting; a.ops.opt_having = opt_having; return a;};
  algebra.NewIndexJoin = function(from,join_type,join_term,for_ident)      {var a = new expr("IndexJoin"); a.ops.from = from; a.ops.join_type = join_type; a.ops.join_term = join_term; a.ops.for_ident = for_ident; return a;};
  algebra.NewIndexKeyTerm = function(index_term,opt_dir)                   {var a = new expr("IndexKeyTerm"); a.ops.index_term = index_term; a.ops.opt_dir = opt_dir; return a;};
  algebra.NewIndexNest = function(from,join_type,join_term,for_ident)      {var a = new expr("IndexNest"); a.ops.from = from; a.ops.join_type = join_type; a.ops.join_term = join_term; a.ops.for_ident = for_ident; return a;};
  algebra.NewIndexRef = function(index_name,opt_using)                     {var a = new expr("IndexRef"); a.ops.index_name = index_name; a.ops.opt_using = opt_using; return a;};
  algebra.NewInferKeyspace = function(keyspace,infer_using,infer_with)     {var a = new expr("InferKeyspace"); a.ops.keyspace = keyspace; a.ops.infer_using = infer_using; a.ops.infer_with = infer_with; return a;};
  algebra.NewInsertSelect = function(keyspace,key_expr,value_expr,fullselect,returning) {var a = new expr("InsertSelect"); a.ops.keyspace = keyspace; a.ops.key_expr = key_expr; a.ops.value_expr = value_expr; return a;};
  algebra.NewInsertValues = function(keyspace,values_header,values_list,returning) {var a = new expr("InsertValues"); a.ops.values_header = values_header, a.ops.values_list = values_list; a.ops.returning = returning; return a;};
  algebra.NewIntersect = function(select_terms,intersect_term)             {var a = new expr("Intersect"); a.ops.elect_terms = elect_terms; a.ops.intersect_term = intersect_term; return a;};
  algebra.NewIntersectAll = function(select_terms,intersect_term)          {var a = new expr("IntersectAll"); a.ops.select_terms = select_terms; a.ops.intersect_term = intersect_term; return a;};
  algebra.NewJoin = function(from,join_type,join_term)                     {var a = new expr("Join"); a.ops.from = from; a.ops.join_type = join_type; a.ops.join_term = join_term; return a;};
  algebra.NewKeyspaceRef = function(namespace,keyspace,alias)              {var a = new expr("KeyspaceRef"); a.ops.namespace = namespace; a.ops.keyspace = keyspace; a.ops.alias = alias; return a;};
  algebra.NewKeyspaceTerm = function(namespace,keyspace,as_alias,opt_use)  {var a = new expr("KeyspaceTerm",keyspace); a.ops.namespace = namespace; a.ops.keyspace = keyspace; a.ops.as_alias = as_alias; a.ops.opt_use = opt_use; return a;};
  algebra.NewMerge = function(keyspace,merge_source,key,merge_actions,opt_limit,returning) {var a = new expr("Merge"); a.ops.keyspace = keyspace; a.ops.merge_source = merge_source; a.ops.key = key; a.ops.merge_actions = merge_actions; a.ops.opt_limit = opt_limit; a.ops.returning = returning; return a;};
  algebra.NewMergeActions = function(update,del,insert)                    {var a = new expr("MergeActions"); a.ops.update = update; a.ops.del = del; a.ops.insert = insert; return a;};
  algebra.NewMergeDelete = function(where)                                 {var a = new expr("MergeDelete"); a.ops.where = where; return a;};
  algebra.NewMergeInsert = function(expression,where)                      {var a = new expr("MergeInsert"); a.ops.expression = expression; a.ops.where = where; return a;};
  algebra.NewMergeSourceExpression = function(expression,alias)            {var a = new expr("MergeSourceSelect"); a.ops.expression = expression; a.ops.alias = alias; return a;};
  algebra.NewMergeSourceFrom = function(from,alias)                        {var a = new expr("MergeSourceSelect"); a.ops.from = from; a.ops.alias = alias; return a;};
  algebra.NewMergeSourceSelect = function(from,alias)                      {var a = new expr("MergeSourceSelect"); a.ops.from = from; a.ops.alias = alias; return a;};
  algebra.NewMergeUpdate = function(set,unset,where)                       {var a = new expr("MergeUpdate"); a.ops.set = set; a.ops.unset = unset; a.ops.where = where; return a;};
  algebra.NewNamedParameter = function(named_param)                        {var a = new expr("NamedParameter"); a.ops.named_param = named_param; return a;};
  algebra.NewNest = function(from,join_type,join_term)                     {var a = new expr("Nest"); a.ops.from = from; a.ops.join_type = join_type; a.ops.join_term = join_term; return a;};
  algebra.NewOrder = function(sort_terms)                                  {var a = new expr("Order"); a.ops.sort_terms = sort_terms; return a;};
  algebra.NewPair = function(first,second)                                 {var a = new expr("Pair"); a.ops.first = first; a.ops.second = second; return a;};
  algebra.NewPositionalParameter = function(positional_param)              {var a = new expr("PositionalParameter"); a.ops.positional_param = positional_param; return a;};
  algebra.NewPrepare = function(name,statement)                            {var a = new expr("Prepare"); a.ops.name = name; a.ops.statement = statement; return a;};
  algebra.NewProjection = function(distinct,projects)                      {var a = new expr("Projection"); a.ops.distinct = distinct; a.ops.projects = projects; return a;};
  algebra.NewRawProjection = function(distinct,expression,as_alias)        {var a = new expr("RawProjection"); a.ops.distinct = distinct; a.ops.expression = expression; a.ops.as_alias = as_alias; return a;};
  algebra.NewResultTerm = function(expression,star,as_alias)               {var a = new expr("ResultTerm"); a.ops.expression = expression; a.ops.star = star; a.ops.as_alias = as_alias; return a;};
  algebra.NewRevokeRule = function(role_list,user_list,keyspace_list)      {var a = new expr("RevokeRule"); a.ops.role_list = role_list; a.ops.user_list = user_list; a.ops.keyspace_list = keyspace_list; return a;};
  algebra.NewSelect = function(select_terms,order_by,offset,limit)         {var a = new expr("Select"); a.ops.select_terms = select_terms; a.ops.order_by = order_by; a.ops.offset = offset; a.ops.limit = limit; return a;};
  algebra.NewSelectTerm = function(term)                                   {var a = new expr("SelectTerm"); a.ops.term = term; return a;};
  algebra.NewSet = function(set_terms)                                     {var a = new expr("Set"); a.ops.set_terms = set_terms; return a;};
  algebra.NewSetTerm = function(path,expression,update_for)                {var a = new expr("SetTerm"); a.ops.path = path; a.ops.expression = expression; a.ops.update_for = update_for; return a;};
  algebra.NewSortTerm = function(expression,desc)                          {var a = new expr("SortTerm"); a.ops.expression = expression; a.ops.desc = desc; return a;};
  algebra.NewSubquery = function(fullselect)                               {var a = new expr("Subquery"); a.ops.fullselect = fullselect; return a;};
  algebra.NewSubqueryTerm = function(select_term,as_alias)                 {var a = new expr("SubqueryTerm"); a.ops.select_term = select_term; a.ops.as_alias = as_alias; return a;};
  algebra.NewSubselect = function(from,let,where,group,select)             {var a = new expr("Subselect"); a.ops.from = from; a.ops.let = let; a.ops.where = where; a.ops.group = group; a.ops.select = select; return a;};
  algebra.NewUnion = function(first,second)                                {var a = new expr("Union"); a.ops.first = first; a.ops.second = second; return a;};
  algebra.NewUnionAll = function(first,second)                             {var a = new expr("UnionAll"); a.ops.first = first; a.ops.second = second; return a;};
  algebra.NewUnnest = function(from,join_type,expression,as_alias)         {var a = new expr("Unnest"); a.ops.from = from; a.ops.join_type = join_type; a.ops.expression = expression; a.ops.as_alias = as_alias; return a;};
  algebra.NewUnset = function(unset_terms)                                 {var a = new expr("Unset"); a.ops.unset_terms = unset_terms; return a;};
  algebra.NewUnsetTerm = function(path,update_for)                         {var a = new expr("UnsetTerm"); a.ops.path = path; a.ops.update_for = update_for; return a;};
  algebra.NewUpdate = function(keyspace,use_keys,use_indexes,set,unset,where,limit,returning) {var a = new expr("Update"); a.ops.keyspace = keyspace; a.ops.use_keys = use_keys; a.ops.use_indexes = use_indexes; a.ops.set = set; a.ops.unset = unset; a.ops.where = where; a.ops.limit = limit; a.ops.returning = returning; return a;};
  algebra.NewUpdateFor = function(update_dimensions,when)                  {var a = new expr("UpdateFor"); a.ops.update_dimensions = update_dimensions; a.ops.when = when; return a;};
  algebra.NewUpsertSelect = function(keyspace,key_expr,value_expr,fullselect,returning) {var a = new expr("UpsertSelect"); a.ops.keyspace = keyspace; a.ops.key_expr = key_expr; a.ops.value_expr = value_expr; a.ops.fullselect = fullselect; a.ops.returning = returning; return a;};
  algebra.NewUpsertValues = function(keyspace,values_list,returning)       {var a = new expr("UpsertValues"); a.ops.keyspace = keyspace; a.ops.values_list = values_list; a.ops.returning = returning; return a;};
  algebra.NewUse = function(keys,index)                                    {var a = new expr("Use"); a.ops.keys = keys; a.ops.index = index; return a;};

  algebra.SubqueryTerm = "SubqueryTerm";
  algebra.ExpressionTerm = "ExpressionTerm";
  algebra.KeyspaceTerm = "KeyspaceTerm";

  var value = {};
  value.NewValue = function(val) {var a = new expr("Value"); a.value = val; return a;};

  var datastore = {
    INF_DEFAULT : "INF_DEFAULT",
    DEFAULT : "DEFAULT",
    VIEW : "VIEW",
    GSI : "GSI",
    FTS : "FTS"    
  };
  
  var nil = null;

  var statement_count = 0;

  var yylex = {
    Error: function(message) {console.log(message);}
  };
%}

%lex

qidi			    [`](([`][`])|[^`])+[`][i]
qid			    [`](([`][`])|[^`])+[`]

%options flex case-insensitive

%%


\"((\\\")|[^\"])*\" { return 'STR'; }

\'(('')|[^\'])*\'   { return 'STR'; }

{qidi}              { yytext = yytext.substring(1,yytext.length -2).replace("``","`"); return 'IDENT_ICASE'; }

{qid}               { yytext = yytext.substring(1,yytext.length -1).replace("``","`"); return 'IDENT'; }
		      	     	      
(0|[1-9][0-9]*)\.[0-9]+([eE][+\-]?[0-9]+)? { return 'NUM'; }

(0|[1-9][0-9]*)[eE][+\-]?[0-9]+ { return 'NUM';  }

0|[1-9][0-9]* { return 'NUM'; }

(\/\*)([^\*]|(\*)+[^\/])*((\*)+\/) /* eat up block comment */ 

"--"[^\n\r]*	  /* eat up line comment */ 

[ \t\n\r\f]+	  /* eat up whitespace */ 

"."		  { return ("DOT"); }
"+"		  { return ("PLUS"); }
"*"		  { return ("STAR"); }
"/"		  { return ("DIV"); }
"-"		  { return ("MINUS"); }
"%"		  { return ("MOD"); }
"=="		  { return ("DEQ"); }
"="		  { return ("EQ"); }
"!="		  { return ("NE"); }
"<>"		  { return ("NE"); }
"<"		  { return ("LT"); }
"<="		  { return ("LE"); }
">"		  { return ("GT"); }
">="		  { return ("GE"); }
"||"		  { return ("CONCAT"); }
"("		  { return ("LPAREN"); }
")"		  { return ("RPAREN"); }
"{"		  { return ("LBRACE"); }
"}"		  { return ("RBRACE"); }
","		  { return ("COMMA"); }
":"		  { return ("COLON"); }
"["		  { return ("LBRACKET"); }
"]"		  { return ("RBRACKET"); }
"]i"		  { return ("RBRACKET_ICASE"); }
";"		  { return ("SEMI"); }
"!"		  { return ("NOT_A_TOKEN"); }

<<EOF>>           { return 'EOF'; }

 
\$[a-zA-Z_][a-zA-Z0-9_]*   { return 'NAMED_PARAM'; }

\$[1-9][0-9]*		   { return 'POSITIONAL_PARAM'; }

\?			   { return 'NEXT_PARAM'; }


"all" 	    			{ return("ALL"); }
"alter"				{ return("ALTER"); }
"analyze"			{ return("ANALYZE"); }
"and"				{ return("AND"); }
"any"				{ return("ANY"); }
"array"				{ return("ARRAY"); }
"as"				{ return("AS"); }
"asc"				{ return("ASC"); }
"begin"				{ return("BEGIN"); }
"between"			{ return("BETWEEN"); }
"binary"			{ return("BINARY"); }
"boolean"			{ return("BOOLEAN"); }
"break"				{ return("BREAK"); }
"bucket"			{ return("BUCKET"); }
"build"				{ return("BUILD"); }
"by"				{ return("BY"); }
"call"				{ return("CALL"); }
"case"				{ return("CASE"); }
"cast"				{ return("CAST"); }
"cluster"			{ return("CLUSTER"); }
"collate"			{ return("COLLATE"); }
"collection"	 		{ return("COLLECTION"); }
"commit"			{ return("COMMIT"); }
"connect"			{ return("CONNECT"); }
"continue"		 	{ return("CONTINUE"); }
"correlate"		 	{ return("CORRELATE"); }
"cover"				{ return("COVER"); }
"create"			{ return("CREATE"); }
"database"			{ return("DATABASE"); }
"dataset"			{ return("DATASET"); }
"datastore"			{ return("DATASTORE"); }
"declare"			{ return("DECLARE"); }
"decrement"			{ return("DECREMENT"); }
"delete"			{ return("DELETE"); }
"derived"			{ return("DERIVED"); }
"desc"				{ return("DESC"); }
"describe"			{ return("DESCRIBE"); }
"distinct"			{ return("DISTINCT"); }
"do"				{ return("DO"); }
"drop"				{ return("DROP"); }
"each"				{ return("EACH"); }
"element"			{ return("ELEMENT"); }
"else"				{ return("ELSE"); }
"end"				{ return("END"); }
"every"				{ return("EVERY"); }
"except"			{ return("EXCEPT"); }
"exclude"			{ return("EXCLUDE"); }
"execute"			{ return("EXECUTE"); }
"exists"			{ return("EXISTS"); }
"explain"			{ return("EXPLAIN") }
"false"				{ return("FALSE"); }
"fetch"				{ return("FETCH"); }
"first"				{ return("FIRST"); }
"flatten"			{ return("FLATTEN"); }
"for"				{ return("FOR"); }
"force"				{ return("FORCE"); }
"from"				{ return("FROM"); }
"fts"				{ return("FTS"); }
"function"			{ return("FUNCTION"); }
"grant"				{ return("GRANT"); }
"group"				{ return("GROUP"); }
"gsi"				{ return("GSI"); }
"having"			{ return("HAVING"); }
"if"				{ return("IF"); }
"ignore"			{ return("IGNORE"); }
"ilike"				{ return("ILIKE"); }
"in"				{ return("IN"); }
"include"			{ return("INCLUDE"); }
"increment"			{ return("INCREMENT"); }
"index"				{ return("INDEX"); }
"infer"				{ return("INFER"); }
"inline"			{ return("INLINE"); }
"inner"				{ return("INNER"); }
"insert"			{ return("INSERT"); }
"intersect"			{ return("INTERSECT"); }
"into"				{ return("INTO"); }
"is"				{ return("IS"); }
"join"				{ return("JOIN"); }
"key"				{ return("KEY"); }
"keys"				{ return("KEYS"); }
"keyspace"			{ return("KEYSPACE"); }
"known"				{ return("KNOWN"); }
"last"				{ return("LAST"); }
"left"				{ return("LEFT"); }
"let"				{ return("LET"); }
"letting"			{ return("LETTING"); }
"like"				{ return("LIKE"); }
"limit"				{ return("LIMIT"); }
"lsm"				{ return("LSM"); }
"map"				{ return("MAP"); }
"mapping"			{ return("MAPPING"); }
"matched"			{ return("MATCHED"); }
"materialized" 			{ return("MATERIALIZED"); }
"merge"				{ return("MERGE"); }
"minus"				{ return("MINUS"); }
"missing"			{ return("MISSING"); }
"namespace"			{ return("NAMESPACE"); }
"nest"				{ return("NEST"); }
"not"				{ return("NOT"); }
"null"				{ return("NULL"); }
"number"			{ return("NUMBER"); }
"object"			{ return("OBJECT"); }
"offset"			{ return("OFFSET"); }
"on"				{ return("ON"); }
"option"			{ return("OPTION"); }
"or"				{ return("OR"); }
"order"				{ return("ORDER"); }
"outer"				{ return("OUTER"); }
"over"				{ return("OVER"); }
"parse"				{ return("PARSE"); }
"partition"			{ return("PARTITION"); }
"password"			{ return("PASSWORD"); }
"path"				{ return("PATH"); }
"pool"				{ return("POOL"); }
"prepare"			{ return("PREPARE") }
"primary"			{ return("PRIMARY"); }
"private"			{ return("PRIVATE"); }
"privilege"			{ return("PRIVILEGE"); }
"procedure"			{ return("PROCEDURE"); }
"public"			{ return("PUBLIC"); }
"raw"				{ return("RAW"); }
"realm"				{ return("REALM"); }
"reduce"			{ return("REDUCE"); }
"rename"			{ return("RENAME"); }
"return"			{ return("RETURN"); }
"returning"			{ return("RETURNING"); }
"revoke"			{ return("REVOKE"); }
"right"				{ return("RIGHT"); }
"role"				{ return("ROLE"); }
"rollback"			{ return("ROLLBACK"); }
"satisfies"			{ return("SATISFIES"); }
"schema"			{ return("SCHEMA"); }
"select"			{ return("SELECT"); }
"self"				{ return("SELF"); }
"set"				{ return("SET"); }
"show"				{ return("SHOW"); }
"some"				{ return("SOME"); }
"start"				{ return("START"); }
"statistics"			{ return("STATISTICS"); }
"string"			{ return("STRING"); }
"system"			{ return("SYSTEM"); }
"then"				{ return("THEN"); }
"to"				{ return("TO"); }
"transaction"			{ return("TRANSACTION"); }
"trigger"			{ return("TRIGGER"); }
"true"				{ return("TRUE"); }
"truncate"			{ return("TRUNCATE"); }
"under"				{ return("UNDER"); }
"union"				{ return("UNION"); }
"unique"			{ return("UNIQUE"); }
"unknown"			{ return("UNKNOWN"); }
"unnest"			{ return("UNNEST"); }
"unset"				{ return("UNSET"); }
"update"			{ return("UPDATE"); }
"upsert"			{ return("UPSERT"); }
"use"				{ return("USE"); }
"user"				{ return("USER"); }
"using"				{ return("USING"); }
"validate"			{ return("VALIDATE"); }
"value"				{ return("VALUE"); }
"valued"			{ return("VALUED"); }
"values"			{ return("VALUES"); }
"via"				{ return("VIA"); }
"view"				{ return("VIEW"); }
"when"				{ return("WHEN"); }
"where"				{ return("WHERE"); }
"while"				{ return("WHILE"); }
"with"				{ return("WITH"); }
"within"			{ return("WITHIN"); }
"work"				{ return("WORK"); }
"xor"				{ return("XOR"); }

[a-zA-Z_][a-zA-Z0-9_]*     { return 'IDENT'; }

/lex

/* Precedence: lowest to highest */
%left           ORDER
%left           UNION INTERESECT EXCEPT
%left           JOIN NEST UNNEST FLATTEN INNER LEFT
%left           OR
%left           AND
%right          NOT
%nonassoc       EQ DEQ NE
%nonassoc       LT GT LE GE
%nonassoc       LIKE
%nonassoc       BETWEEN
%nonassoc       IN WITHIN
%nonassoc       EXISTS
%nonassoc       IS                              /* IS NULL, IS MISSING, IS VALUED, IS NOT NULL, etc. */
%left           CONCAT
%left           PLUS MINUS
%left           STAR DIV MOD

/* Unary operators */
%right          COVER
%left           ALL
%right          UMINUS
%left           DOT LBRACKET RBRACKET

/* Override precedence */
%left           LPAREN RPAREN

%start		input_list

/*****************************************************************************/
/*****************************************************************************/
/*****************************************************************************/

%%

input_list:
inputs {return $1;}
;

inputs:
input EOF
{
    $$ = [$1];
}
|
input SEMI input_list
{
    $3.push($1);
    $$ = $3;
}
;


input:
stmt 
{
    $$ = $1;
}
|
expr_input 
{
    $$ = $1;
}
|
/* empty is o.k. *
{
    $$ = expression.NewEmpty();
}
;

opt_trailer:
{
  /* nothing */
}
|
opt_trailer SEMI
;

stmt:
select_stmt
|
dml_stmt
|
ddl_stmt
|
explain
|
prepare
|
execute
|
infer
|
role_stmt
;

explain:
EXPLAIN stmt
{
    $$ = algebra.NewExplain($2)
}
;

prepare:
PREPARE opt_name stmt
{
    $$ = algebra.NewPrepare($2, $3)
}
;

opt_name:
/* empty */
{
    $$ = ""
}
|
IDENT from_or_as
{
    $$ = $1
}
|
STR from_or_as
{
    $$ = $1
}
;

from_or_as:
FROM
|
AS
;

execute:
EXECUTE expr
{
    $$ = algebra.NewExecute($2)
}
;

infer:
infer_keyspace
;

infer_keyspace:
INFER opt_keyspace keyspace_ref opt_infer_using opt_infer_with
{
    $$ = algebra.NewInferKeyspace($3, $4, $5)
}
;

opt_keyspace:
/* empty */
{
}
|
KEYSPACE
;

opt_infer_using:
/* empty */
{
    $$ = datastore.INF_DEFAULT
}
;

opt_infer_with:
/* empty */
{
    $$ = nil
}
|
infer_with
;

infer_with:
WITH expr
{
    $$ = $2
}
;

select_stmt:
fullselect
{
    $$ = $1
}
;

dml_stmt:
insert
|
upsert
|
delete
|
update
|
merge
;

ddl_stmt:
index_stmt
;

role_stmt:
grant_role
|
revoke_role
;

index_stmt:
create_index
|
drop_index
|
alter_index
|
build_index
;

fullselect:
select_terms opt_order_by
{
    $$ = algebra.NewSelect($1, $2, nil, nil) /* OFFSET precedes LIMIT */
}
|
select_terms opt_order_by limit opt_offset
{
    $$ = algebra.NewSelect($1, $2, $4, $3) /* OFFSET precedes LIMIT */
}
|
select_terms opt_order_by offset opt_limit
{
    $$ = algebra.NewSelect($1, $2, $3, $4) /* OFFSET precedes LIMIT */
}
;

select_terms:
subselect
{
    $$ = $1
}
|
select_terms UNION select_term
{
    $$ = algebra.NewUnion($1, $3)
}
|
select_terms UNION ALL select_term
{
    $$ = algebra.NewUnionAll($1, $4)
}
|
select_terms INTERSECT select_term
{
    $$ = algebra.NewIntersect($1, $3)
}
|
select_terms INTERSECT ALL select_term
{
    $$ = algebra.NewIntersectAll($1, $4)
}
|
select_terms EXCEPT select_term
{
    $$ = algebra.NewExcept($1, $3)
}
|
select_terms EXCEPT ALL select_term
{
    $$ = algebra.NewExceptAll($1, $4)
}
|
subquery_expr UNION select_term
{
    var left_term = algebra.NewSelectTerm($1.Select())
    $$ = algebra.NewUnion(left_term, $3)
}
|
subquery_expr UNION ALL select_term
{
    var left_term = algebra.NewSelectTerm($1.Select())
    $$ = algebra.NewUnionAll(left_term, $4)
}
|
subquery_expr INTERSECT select_term
{
    var left_term = algebra.NewSelectTerm($1.Select())
    $$ = algebra.NewIntersect(left_term, $3)
}
|
subquery_expr INTERSECT ALL select_term
{
    var left_term = algebra.NewSelectTerm($1.Select())
    $$ = algebra.NewIntersectAll(left_term, $4)
}
|
subquery_expr EXCEPT select_term
{
    var left_term = algebra.NewSelectTerm($1.Select())
    $$ = algebra.NewExcept(left_term, $3)
}
|
subquery_expr EXCEPT ALL select_term
{
    var left_term = algebra.NewSelectTerm($1.Select())
    $$ = algebra.NewExceptAll(left_term, $4)
}
;

select_term:
subselect
{
    $$ = $1
}
|
subquery_expr
{
    $$ = algebra.NewSelectTerm($1.Select())
}
;

subselect:
from_select
|
select_from
;

from_select:
from opt_let opt_where opt_group select_clause
{
    $$ = algebra.NewSubselect($1, $2, $3, $4, $5)
}
;

select_from:
select_clause opt_from opt_let opt_where opt_group
{
    $$ = algebra.NewSubselect($2, $3, $4, $5, $1)
}
;


/*************************************************
 *
 * SELECT clause
 *
 *************************************************/

select_clause:
SELECT
projection
{
    $$ = $2
}
;

projection:
projects
{
    $$ = algebra.NewProjection(false, $1)
}
|
DISTINCT projects
{
    $$ = algebra.NewProjection(true, $2)
}
|
ALL projects
{
    $$ = algebra.NewProjection(false, $2)
}
|
raw expr opt_as_alias
{
    $$ = algebra.NewRawProjection(false, $2, $3)
}
|
DISTINCT raw expr opt_as_alias
{
    $$ = algebra.NewRawProjection(true, $3, $4)
}
;

raw:
RAW
|
ELEMENT
|
VALUE
;

projects:
project
{
    $$ = [$1]
}
|
projects COMMA project
{
    $1.push($3);
    $$ = $1;
}
;

project:
STAR
{
    $$ = algebra.NewResultTerm(expression.SELF, true, "");
}
|
expr DOT STAR opt_as_alias
{
    $$ = algebra.NewResultTerm($1, true, $4);
}
|
expr opt_as_alias
{
    $$ = algebra.NewResultTerm($1, false, $2)
}
;

opt_as_alias:
/* empty */
{
    $$ = ""
}
|
as_alias
;

as_alias:
alias
|
AS alias
{
    $$ = $2
}
;

alias:
IDENT
;


/*************************************************
 *
 * FROM clause
 *
 *************************************************/

opt_from:
/* empty */
{
    $$ = nil
}
|
from
;

from:
FROM from_term
{
    $$ = $2
}
;

from_term:
simple_from_term
|
from_term opt_join_type JOIN join_term
{
    $$ = algebra.NewJoin($1, $2, $4)
}
|
from_term opt_join_type JOIN index_join_term FOR IDENT
{
    $$ = algebra.NewIndexJoin($1, $2, $4, $6)
}
|
from_term opt_join_type NEST join_term
{
    $$ = algebra.NewNest($1, $2, $4)
}
|
from_term opt_join_type NEST index_join_term FOR IDENT
{
    $$ = algebra.NewIndexNest($1, $2, $4, $6)
}
|
from_term opt_join_type unnest expr opt_as_alias
{
    $$ = algebra.NewUnnest($1, $2, $4, $5)
}
;

simple_from_term:
keyspace_term
{
    $$ = $1
}
|
expr opt_as_alias opt_use
{
     var other = $1;
     switch ($1.type) {
         case "Subquery":
              if ($2 == "") {
                   yylex.Error("Subquery in FROM clause must have an alias.");
              }
              if ($3 != algebra.EMPTY_USE) {
                   yylex.Error("FROM Subquery cannot have USE KEYS or USE INDEX.");
              }
              $$ = algebra.NewSubqueryTerm(other.Select(), $2);
	      break;
         case "Identifier":
              var ksterm = algebra.NewKeyspaceTerm("", other.Alias(), $2, $3.Keys(), $3.Indexes());
              $$ = algebra.NewExpressionTerm(other, $2, ksterm);
	      break;
         default:
              if ($3 != algebra.EMPTY_USE) {
                  yylex.Error("FROM Expression cannot have USE KEYS or USE INDEX.")
              }
              $$ = algebra.NewExpressionTerm(other,$2, nil);
     }
}
;

unnest:
UNNEST
|
FLATTEN
;

keyspace_term:
namespace_term keyspace_name opt_as_alias opt_use
{
     $$ = algebra.NewKeyspaceTerm($1, $2, $3, $4.Keys(), $4.Indexes())
}
;

join_term:
keyspace_name opt_as_alias on_keys
{
    $$ = algebra.NewKeyspaceTerm("", $1, $2, $3, nil)
}
|
namespace_term keyspace_name opt_as_alias on_keys
{
    $$ = algebra.NewKeyspaceTerm($1, $2, $3, $4, nil)
}
;

index_join_term:
keyspace_name opt_as_alias on_key
{
    $$ = algebra.NewKeyspaceTerm("", $1, $2, $3, nil)
}
|
namespace_term keyspace_name opt_as_alias on_key
{
    $$ = algebra.NewKeyspaceTerm($1, $2, $3, $4, nil)
}
;


namespace_term:
namespace_name
|
SYSTEM COLON
{
    $$ = "#system"
}
;

namespace_name:
IDENT COLON {$$ = $1;}
;

keyspace_name:
IDENT
;

opt_use:
/* empty */
{
    $$ = algebra.EMPTY_USE
}
|
use_keys
{
    $$ = algebra.NewUse($1, nil)
}
|
use_index
{
    $$ = algebra.NewUse(nil, $1)
}
;

use_keys:
USE opt_primary KEYS expr
{
    $$ = $4
}
;

opt_primary:
/* empty */
{
}
|
PRIMARY
;

use_index:
USE INDEX LPAREN index_refs RPAREN
{
    $$ = $4
}
;

index_refs:
index_ref
{
    $$ = [$1]
}
|
index_refs COMMA index_ref
{
    $1.push($3);
    $$ = $1;
}
;

index_ref:
index_name opt_index_using
{
    $$ = algebra.NewIndexRef($1, $2);
}
;

opt_join_type:
/* empty */
{
    $$ = false
}
|
INNER
{
    $$ = false
}
|
LEFT opt_outer
{
    $$ = true
}
;

opt_outer:
/* empty */
|
OUTER
;

on_keys:
ON opt_primary KEYS expr
{
    $$ = $4
}
;

on_key:
ON opt_primary KEY expr
{
    $$ = $4
}
;


/*************************************************
 *
 * LET clause
 *
 *************************************************/

opt_let:
/* empty */
{
    $$ = nil
}
|
let
;

let:
LET bindings
{
    $$ = $2
}
;

bindings:
binding
{
    $$ = [$1]
}
|
bindings COMMA binding
{
    $1.push($3);
    $$ = $1;
}
;

binding:
alias EQ expr
{
    $$ = expression.NewSimpleBinding($1, $3)
}
;


/*************************************************
 *
 * WHERE clause
 *
 *************************************************/

opt_where:
/* empty */
{
    $$ = nil
}
|
where
;

where:
WHERE expr
{
    $$ = $2
}
;


/*************************************************
 *
 * GROUP BY clause
 *
 *************************************************/

opt_group:
/* empty */
{
    $$ = nil
}
|
group
;

group:
GROUP BY exprs opt_letting opt_having
{
    $$ = algebra.NewGroup($3, $4, $5)
}
|
letting
{
    $$ = algebra.NewGroup(nil, $1, nil)
}
;

exprs:
expr
{
    $$ = [$1]
}
|
exprs COMMA expr
{
    $1.push($3);
    $$ = $1
}
;

opt_letting:
/* empty */
{
    $$ = nil
}
|
letting
;

letting:
LETTING bindings
{
    $$ = $2
}
;

opt_having:
/* empty */
{
    $$ = nil
}
|
having
;

having:
HAVING expr
{
    $$ = $2
}
;


/*************************************************
 *
 * ORDER BY clause
 *
 *************************************************/

opt_order_by:
/* empty */
{
    $$ = nil
}
|
order_by
;

order_by:
ORDER BY sort_terms
{
    $$ = algebra.NewOrder($3)
}
;

sort_terms:
sort_term
{
    $$ = [$1]
}
|
sort_terms COMMA sort_term
{
    $1.push($3);
    $$ = $1;
}
;

sort_term:
expr opt_dir
{
    $$ = algebra.NewSortTerm($1, $2)
}
;

opt_dir:
/* empty */
{
    $$ = false
}
|
dir
;

dir:
ASC
{
    $$ = false
}
|
DESC
{
    $$ = true
}
;


/*************************************************
 *
 * LIMIT clause
 *
 *************************************************/

opt_limit:
/* empty */
{
    $$ = nil
}
|
limit
;

limit:
LIMIT expr
{
    $$ = $2
}
;


/*************************************************
 *
 * OFFSET clause
 *
 *************************************************/

opt_offset:
/* empty */
{
    $$ = nil
}
|
offset
;

offset:
OFFSET expr
{
    $$ = $2
}
;


/*************************************************
 *
 * INSERT
 *
 *************************************************/

insert:
INSERT INTO keyspace_ref opt_values_header values_list opt_returning
{
    $$ = algebra.NewInsertValues($3, $5, $6)
}
|
INSERT INTO keyspace_ref LPAREN key_expr opt_value_expr RPAREN fullselect opt_returning
{
    $$ = algebra.NewInsertSelect($3, $5, $6, $8, $9)
}
;

keyspace_ref:
namespace_term keyspace_name opt_as_alias
{
    $$ = algebra.NewKeyspaceRef($1, $2, $3)
}
|
keyspace_name opt_as_alias
{
    $$ = algebra.NewKeyspaceRef("", $1, $2)
}
;

opt_values_header:
/* empty */
|
LPAREN KEY COMMA VALUE RPAREN
|
LPAREN PRIMARY KEY COMMA VALUE RPAREN
;

key:
KEY
|
PRIMARY KEY
;

values_list:
values {$$=$1;}
|
values_list COMMA next_values
{
    $1.push($3);
    $$ = $1;
}
;

values:
VALUES LPAREN expr COMMA expr RPAREN
{
    $$ = [{Key: $3, Value: $5}];
}
;

next_values:
values {$$ = $1;}
|
LPAREN expr COMMA expr RPAREN
{
    $$ = [{Key: $2, Value: $4}];
}
;

opt_returning:
/* empty */
{
    $$ = nil
}
|
returning
;

returning:
RETURNING returns
{
    $$ = $2
}
;

returns:
projects
{
    $$ = algebra.NewProjection(false, $1)
}
|
raw expr
{
    $$ = algebra.NewRawProjection(false, $2, "")
}
;

key_expr:
key expr
{
    $$ = $2
}
;

opt_value_expr:
/* empty */
{
    $$ = nil
}
|
COMMA VALUE expr
{
    $$ = $3
}
;


/*************************************************
 *
 * UPSERT
 *
 *************************************************/

upsert:
UPSERT INTO keyspace_ref opt_values_header values_list opt_returning
{
    $$ = algebra.NewUpsertValues($3, $5, $6)
}
|
UPSERT INTO keyspace_ref LPAREN key_expr opt_value_expr RPAREN fullselect opt_returning
{
    $$ = algebra.NewUpsertSelect($3, $5, $6, $8, $9)
}
;


/*************************************************
 *
 * DELETE
 *
 *************************************************/

delete:
DELETE FROM keyspace_ref opt_use opt_where opt_limit opt_returning
{
    $$ = algebra.NewDelete($3, $4.Keys(), $4.Indexes(), $5, $6, $7)
}
;


/*************************************************
 *
 * UPDATE
 *
 *************************************************/

update:
UPDATE keyspace_ref opt_use set unset opt_where opt_limit opt_returning
{
    $$ = algebra.NewUpdate($2, $3.Keys(), $3.Indexes(), $4, $5, $6, $7, $8)
}
|
UPDATE keyspace_ref opt_use set opt_where opt_limit opt_returning
{
    $$ = algebra.NewUpdate($2, $3.Keys(), $3.Indexes(), $4, nil, $5, $6, $7)
}
|
UPDATE keyspace_ref opt_use unset opt_where opt_limit opt_returning
{
    $$ = algebra.NewUpdate($2, $3.Keys(), $3.Indexes(), nil, $4, $5, $6, $7)
}
;

set:
SET set_terms
{
    $$ = algebra.NewSet($2)
}
;

set_terms:
set_term
{
    $$ = [$1];
}
|
set_terms COMMA set_term
{
    $1.push($3);
    $$ = $1;
}
;

set_term:
path EQ expr opt_update_for
{
    $$ = algebra.NewSetTerm($1, $3, $4)
}
;

opt_update_for:
/* empty */
{
    $$ = nil
}
|
update_for
;

update_for:
update_dimensions opt_when END
{
    $$ = algebra.NewUpdateFor($1, $2)
}
;

update_dimensions:
FOR update_dimension
{
    $$ = [$2];
}
|
update_dimensions FOR update_dimension
{
    dims = [$3,$1];
}
;

update_dimension:
update_binding
{
    $$ = [$1]
}
|
update_dimension COMMA update_binding
{
    $1.push($3);
    $$ = $1;
}
;

update_binding:
variable IN expr
{
    $$ = expression.NewSimpleBinding($1, $3)
}
|
variable WITHIN expr
{
    $$ = expression.NewBinding("", $1, $3, true)
}
|
variable COLON variable IN expr
{
    $$ = expression.NewBinding($1, $3, $5, false)
}
|
variable COLON variable WITHIN expr
{
    $$ = expression.NewBinding($1, $3, $5, true)
}
;

variable:
IDENT
;

opt_when:
/* empty */
{
    $$ = nil
}
|
WHEN expr
{
    $$ = $2
}
;

unset:
UNSET unset_terms
{
    $$ = algebra.NewUnset($2)
}
;

unset_terms:
unset_term
{
    $$ = [$1]
}
|
unset_terms COMMA unset_term
{
    $1.push($3);
    $$ = $1;
}
;

unset_term:
path opt_update_for
{
    $$ = algebra.NewUnsetTerm($1, $2)
}
;


/*************************************************
 *
 * MERGE
 *
 *************************************************/

merge:
MERGE INTO keyspace_ref USING simple_from_term ON key_expr merge_actions opt_limit opt_returning
{
     switch ($5.type) {
         case algebra.SubqueryTerm:
              var source = algebra.NewMergeSourceSelect($5.Subquery(), $5.Alias())
              $$ = algebra.NewMerge($3, source, $7, $8, $9, $10)
         case algebra.ExpressionTerm:
              var source = algebra.NewMergeSourceExpression($5, "")
              $$ = algebra.NewMerge($3, source, $7, $8, $9, $10)
         case algebra.KeyspaceTerm:
              var source = algebra.NewMergeSourceFrom($5, "")
              $$ = algebra.NewMerge($3, source, $7, $8, $9, $10)
         default:
	      yylex.Error("MERGE source term is UNKNOWN.")
     }
}
;

merge_actions:
/* empty */
{
    $$ = algebra.NewMergeActions(nil, nil, nil)
}
|
WHEN MATCHED THEN UPDATE merge_update opt_merge_delete_insert
{
    $$ = algebra.NewMergeActions($5, $6.Delete(), $6.Insert())
}
|
WHEN MATCHED THEN DELETE merge_delete opt_merge_insert
{
    $$ = algebra.NewMergeActions(nil, $5, $6)
}
|
WHEN NOT MATCHED THEN INSERT merge_insert
{
    $$ = algebra.NewMergeActions(nil, nil, $6)
}
;

opt_merge_delete_insert:
/* empty */
{
    $$ = algebra.NewMergeActions(nil, nil, nil)
}
|
WHEN MATCHED THEN DELETE merge_delete opt_merge_insert
{
    $$ = algebra.NewMergeActions(nil, $5, $6)
}
|
WHEN NOT MATCHED THEN INSERT merge_insert
{
    $$ = algebra.NewMergeActions(nil, nil, $6)
}
;

opt_merge_insert:
/* empty */
{
    $$ = nil
}
|
WHEN NOT MATCHED THEN INSERT merge_insert
{
    $$ = $6
}
;

merge_update:
set opt_where
{
    $$ = algebra.NewMergeUpdate($1, nil, $2)
}
|
set unset opt_where
{
    $$ = algebra.NewMergeUpdate($1, $2, $3)
}
|
unset opt_where
{
    $$ = algebra.NewMergeUpdate(nil, $1, $2)
}
;

merge_delete:
opt_where
{
    $$ = algebra.NewMergeDelete($1)
}
;

merge_insert:
expr opt_where
{
    $$ = algebra.NewMergeInsert($1, $2)
}
;

/*************************************************
 *
 * GRANT ROLE
 *
 *************************************************/

grant_role:
GRANT ROLE role_list TO user_list
{
	$$ = algebra.NewGrantRole($3, $5)
}
|
GRANT role_list ON keyspace_list TO user_list
{
    $$ = algebra.NewGrantRole($2, $6, $4)
}
;

role_list:
role_name
{
	$$ = [$1];
}
|
role_list COMMA role_name
{
	$1.push($3);
	$$ = $1;
}
;

role_name:
IDENT
{
    $$ = $1
}
|
SELECT
{
    $$ = "select"
}
|
INSERT
{
    $$ = "insert"
}
|
UPDATE
{
    $$ = "update"
}
|
DELETE
{
    $$ = "delete"
}
;

keyspace_list:
IDENT
{
    $$ = [$1];
}
|
keyspace_list COMMA IDENT
{
    $1.push($3);
    $$ = $1;
}
;

user_list:
user
{
    $$ = [$1]
}
|
user_list COMMA user
{
    $1.push($3);
    $$ = $1;
}
;

user:
IDENT
{
    $$ = $1;
}
|
IDENT COLON IDENT
{
    $$ = $1 + ":" + $3;
}
;

/*************************************************
 *
 * REVOKE ROLE
 *
 *************************************************/

revoke_role:
REVOKE role_list FROM user_list
{
    $$ = algebra.NewRevokeRole($2, $4);
}
|
REVOKE role_list ON keyspace_list FROM user_list
{
    $$ = algebra.NewRevokeRole($2, $6, $4);
}
;


/*************************************************
 *
 * CREATE INDEX
 *
 *************************************************/

create_index:
CREATE PRIMARY INDEX opt_primary_name ON named_keyspace_ref opt_index_using opt_index_with
{
    $$ = algebra.NewCreatePrimaryIndex($4, $6, $7, $8)
}
|
CREATE INDEX index_name ON named_keyspace_ref LPAREN index_terms RPAREN index_partition index_where opt_index_using opt_index_with
{
    $$ = algebra.NewCreateIndex($3, $5, $7, $9, $10, $11, $12)
}
;

opt_primary_name:
/* empty */
{
    $$ = "#primary"
}
|
index_name
;

index_name:
IDENT
;

named_keyspace_ref:
keyspace_name
{
    $$ = algebra.NewKeyspaceRef("", $1, "")
}
|
namespace_term keyspace_name
{
    $$ = algebra.NewKeyspaceRef($1, $2, "")
}
;

index_partition:
/* empty */
{
    $$ = nil
}
|
PARTITION BY exprs
{
    $$ = $3
}
;

opt_index_using:
/* empty */
{
    $$ = datastore.DEFAULT
}
|
index_using
;

index_using:
USING VIEW
{
    $$ = datastore.VIEW
}
|
USING GSI
{
    $$ = datastore.GSI
}
|
USING FTS
{
    $$ = datastore.FTS
}
;

opt_index_with:
/* empty */
{
    $$ = nil
}
|
index_with
;

index_with:
WITH expr
{
    $$ = $2.Value()
    if ($$ == nil) {
	yylex.Error("WITH value must be static.")
    }
}
;

index_terms:
index_term
{
    $$ = [$1]
}
|
index_terms COMMA index_term
{
    $1.push($3);
    $$ = $1;
}
;

index_term:
index_term_expr opt_dir
{
   $$ = algebra.NewIndexKeyTerm($1, $2)
}
;

index_term_expr:
index_expr
|
all index_expr
{
    $$ = expression.NewAll($2, false)
}
|
all DISTINCT index_expr
{
    $$ = expression.NewAll($3, true)
}
|
DISTINCT index_expr
{
    $$ = expression.NewAll($2, true)
}
;

index_expr:
expr
{
    var exp = $1
    if (exp != nil && (!exp.Indexable() || exp.Value() != nil)) {
        yylex.Error(fmt.Sprintf("Expression not indexable: %s", exp.String()))
    }

    $$ = exp
}
;

all:
ALL
|
EACH
;

index_where:
/* empty */
{
    $$ = nil
}
|
WHERE index_expr
{
    $$ = $2
}
;


/*************************************************
 *
 * DROP INDEX
 *
 *************************************************/

drop_index:
DROP PRIMARY INDEX ON named_keyspace_ref opt_index_using
{
    $$ = algebra.NewDropIndex($5, "#primary", $6) 
}
|
DROP INDEX named_keyspace_ref DOT index_name opt_index_using
{
    $$ = algebra.NewDropIndex($3, $5, $6)
}
;

/*************************************************
 *
 * ALTER INDEX
 *
 *************************************************/

alter_index:
ALTER INDEX named_keyspace_ref DOT index_name opt_index_using rename
{
    $$ = algebra.NewAlterIndex($3, $5, $6, $7)
}
;

rename:
/* empty */
{
    $$ = ""
}
|
RENAME TO index_name
{
    $$ = $3
}
;

/*************************************************
 *
 * BUILD INDEX
 *
 *************************************************/

build_index:
BUILD INDEX ON named_keyspace_ref LPAREN index_names RPAREN opt_index_using
{
    $$ = algebra.NewBuildIndexes($4, $8, $6)
}
;

index_names:
index_name
{
    $$ = [];
}
|
index_names COMMA index_name
{
    $1.push($3);
    $$ = $1;
}
;


/*************************************************
 *
 * Path
 *
 *************************************************/

path:
IDENT
{
    $$ = expression.NewIdentifier($1)
}
|
path DOT IDENT
{
    $$ = expression.NewField($1, expression.NewFieldName($3, false));
}
|
path DOT IDENT_ICASE
{
    var field = expression.NewField($1, expression.NewFieldName($3, true))
    field.SetCaseInsensitive = true;
    $$ = field
}
|
path DOT LBRACKET expr RBRACKET
{
    $$ = expression.NewField($1, $4)
}
|
path DOT LBRACKET expr RBRACKET_ICASE
{
    var field = expression.NewField($1, $4)
    field.SetCaseInsensitive = true;
    $$ = field
}
|
path LBRACKET expr RBRACKET
{
    $$ = expression.NewElement($1, $3)
}
;


/*************************************************
 *
 * Expression
 *
 *************************************************/

expr:
c_expr
|
/* Nested */
expr DOT IDENT
{
    $$ = expression.NewField($1, expression.NewFieldName($3, false))
}
|
expr DOT IDENT_ICASE
{
    var field = expression.NewField($1, expression.NewFieldName($3, true))
    field.SetCaseInsensitive = true;
    $$ = field
}
|
expr DOT LBRACKET expr RBRACKET
{
    $$ = expression.NewField($1, $4)
}
|
expr DOT LBRACKET expr RBRACKET_ICASE
{
    var field = expression.NewField($1, $4)
    field.SetCaseInsensitive = true;
    $$ = field
}
|
expr LBRACKET expr RBRACKET
{
    $$ = expression.NewElement($1, $3)
}
|
expr LBRACKET expr COLON RBRACKET
{
    $$ = expression.NewSlice($1, $3)
}
|
expr LBRACKET expr COLON expr RBRACKET
{
    $$ = expression.NewSlice($1, $3, $5)
}
|
expr LBRACKET STAR RBRACKET
{
    $$ = expression.NewArrayStar($1)
}
|
/* Arithmetic */
expr PLUS expr
{
    $$ = expression.NewAdd($1, $3)
}
|
expr MINUS expr
{
    $$ = expression.NewSub($1, $3)
}
|
expr STAR expr
{
    $$ = expression.NewMult($1, $3)
}
|
expr DIV expr
{
    $$ = expression.NewDiv($1, $3)
}
|
expr MOD expr
{
    $$ = expression.NewMod($1, $3)
}
|
/* Concat */
expr CONCAT expr
{
    $$ = expression.NewConcat($1, $3)
}
|
/* Logical */
expr AND expr
{
    $$ = expression.NewAnd($1, $3)
}
|
expr OR expr
{
    $$ = expression.NewOr($1, $3)
}
|
NOT expr
{
    $$ = expression.NewNot($2)
}
|
/* Comparison */
expr EQ expr
{
    $$ = expression.NewEq($1, $3)
}
|
expr DEQ expr
{
    $$ = expression.NewEq($1, $3)
}
|
expr NE expr
{
    $$ = expression.NewNE($1, $3)
}
|
expr LT expr
{
    $$ = expression.NewLT($1, $3)
}
|
expr GT expr
{
    $$ = expression.NewGT($1, $3)
}
|
expr LE expr
{
    $$ = expression.NewLE($1, $3)
}
|
expr GE expr
{
    $$ = expression.NewGE($1, $3)
}
|
expr BETWEEN b_expr AND b_expr
{
    $$ = expression.NewBetween($1, $3, $5)
}
|
expr NOT BETWEEN b_expr AND b_expr
{
    $$ = expression.NewNotBetween($1, $4, $6)
}
|
expr LIKE expr
{
    $$ = expression.NewLike($1, $3)
}
|
expr NOT LIKE expr
{
    $$ = expression.NewNotLike($1, $4)
}
|
expr IN expr
{
    $$ = expression.NewIn($1, $3)
}
|
expr NOT IN expr
{
    $$ = expression.NewNotIn($1, $4)
}
|
expr WITHIN expr
{
    $$ = expression.NewWithin($1, $3)
}
|
expr NOT WITHIN expr
{
    $$ = expression.NewNotWithin($1, $4)
}
|
expr IS NULL
{
    $$ = expression.NewIsNull($1)
}
|
expr IS NOT NULL
{
    $$ = expression.NewIsNotNull($1)
}
|
expr IS MISSING
{
    $$ = expression.NewIsMissing($1)
}
|
expr IS NOT MISSING
{
    $$ = expression.NewIsNotMissing($1)
}
|
expr IS valued
{
    $$ = expression.NewIsValued($1)
}
|
expr IS NOT valued
{
    $$ = expression.NewIsNotValued($1)
}
|
EXISTS expr
{
    $$ = expression.NewExists($2)
}
;

valued:
VALUED
|
KNOWN
;

c_expr:
/* Literal */
literal
|
/* Construction */
construction_expr
|
/* Identifier */
IDENT
{
    $$ = expression.NewIdentifier($1)
}
|
/* Identifier */
IDENT_ICASE
{
    var ident = expression.NewIdentifier($1)
    ident.SetCaseInsensitive = true;
    $$ = ident
}
|
/* Self */
SELF
{
    $$ = expression.NewSelf()
}
|
/* Parameter */
param_expr
|
/* Function */
function_expr
|
/* Prefix */
MINUS expr %prec UMINUS
{
    $$ = expression.NewNeg($2)
}
|
/* Case */
case_expr
|
/* Collection */
collection_expr
|
/* Grouping and subquery */
paren_expr
|
/* For covering indexes */
COVER expr
{
    $$ = expression.NewCover($2)
}
;

b_expr:
c_expr
|
/* Nested */
b_expr DOT IDENT
{
    $$ = expression.NewField($1, expression.NewFieldName($3, false));
}
|
b_expr DOT IDENT_ICASE
{
    var field = expression.NewField($1, expression.NewFieldName($3, true))
    field.SetCaseInsensitive = true;
    $$ = field
}
|
b_expr DOT LBRACKET expr RBRACKET
{
    $$ = expression.NewField($1, $4)
}
|
b_expr DOT LBRACKET expr RBRACKET_ICASE
{
    var field = expression.NewField($1, $4)
    field.SetCaseInsensitive = true;
    $$ = field
}
|
b_expr LBRACKET expr RBRACKET
{
    $$ = expression.NewElement($1, $3)
}
|
b_expr LBRACKET expr COLON RBRACKET
{
    $$ = expression.NewSlice($1, $3)
}
|
b_expr LBRACKET expr COLON expr RBRACKET
{
    $$ = expression.NewSlice($1, $3, $5)
}
|
b_expr LBRACKET STAR RBRACKET
{
    $$ = expression.NewArrayStar($1)
}
|
/* Arithmetic */
b_expr PLUS b_expr
{
    $$ = expression.NewAdd($1, $3)
}
|
b_expr MINUS b_expr
{
    $$ = expression.NewSub($1, $3)
}
|
b_expr STAR b_expr
{
    $$ = expression.NewMult($1, $3)
}
|
b_expr DIV b_expr
{
    $$ = expression.NewDiv($1, $3)
}
|
b_expr MOD b_expr
{
    $$ = expression.NewMod($1, $3)
}
|
/* Concat */
b_expr CONCAT b_expr
{
    $$ = expression.NewConcat($1, $3)
}
;


/*************************************************
 *
 * Literal
 *
 *************************************************/

literal:
NULL
{
    $$ = expression.NULL_EXPR
}
|
MISSING
{
    $$ = expression.MISSING_EXPR
}
|
FALSE
{
    $$ = expression.FALSE_EXPR
}
|
TRUE
{
    $$ = expression.TRUE_EXPR
}
|
NUM
{
    $$ = expression.NewConstant(value.NewValue($1))
}
|
INT
{
    $$ = expression.NewConstant(value.NewValue($1))
}
|
STR
{
    $$ = expression.NewConstant(value.NewValue($1))
}
;


/*************************************************
 *
 * Construction
 *
 *************************************************/

construction_expr:
object
|
array
;

object:
LBRACE opt_members RBRACE
{
    $$ = expression.NewObjectConstruct(algebra.MapPairs($2))
}
;

opt_members:
/* empty */
{
    $$ = nil
}
|
members
;

members:
member
{
    $$ = [$1]
}
|
members COMMA member
{
    $1.push($3);
    $$ = $1;
}
;

member:
expr COLON expr
{
    $$ = algebra.NewPair($1, $3)
}
|
expr
{
    var name = $1.Alias()
    if (name == "") {
        yylex.Error(fmt.Sprintf("Object member missing name or value: %s", $1.String()))
    }

    $$ = algebra.NewPair(expression.NewConstant(name), $1)
}
;

array:
LBRACKET opt_exprs RBRACKET
{
    $$ = expression.NewArrayConstruct($2)
}
;

opt_exprs:
/* empty */
{
    $$ = nil
}
|
exprs
;


/*************************************************
 *
 * Parameter
 *
 *************************************************/

param_expr:
NAMED_PARAM
{
    $$ = algebra.NewNamedParameter($1);
}
|
POSITIONAL_PARAM
{
    $$ = algebra.NewPositionalParameter($1);
}
|
NEXT_PARAM
{
    $$ = algebra.NewPositionalParameter($1);
}
;


/*************************************************
 *
 * Case
 *
 *************************************************/

case_expr:
CASE simple_or_searched_case END
{
    $$ = $2
}
;

simple_or_searched_case:
simple_case
|
searched_case
;

simple_case:
expr when_thens opt_else
{
    $$ = expression.NewSimpleCase($1, $2, $3)
}
;

when_thens:
WHEN expr THEN expr
{
    $$ = [{when: $2, then: $4}]
}
|
when_thens WHEN expr THEN expr
{
    $1.push({when: $3, then: $5});
    $$ = $1;
}
;

searched_case:
when_thens
opt_else
{
    $$ = expression.NewSearchedCase($1, $2)
}
;

opt_else:
/* empty */
{
    $$ = nil
}
|
ELSE expr
{
    $$ = $2
}
;


/*************************************************
 *
 * Function
 *
 *************************************************/

function_expr:
function_name opt_exprs RPAREN
{
    $$ = expression.NewFunction($1,$2);
}
|
function_name DISTINCT expr RPAREN
{
    $$ = expression.NewFunction($1,$3,true);
}
|
function_name STAR RPAREN
{
    $$ = expression.NewFunction($1,"star");
}
;

function_name:
IDENT LPAREN {$$ = $1;}
;


/*************************************************
 *
 * Collection
 *
 *************************************************/

collection_expr:
collection_cond
|
collection_xform
;

collection_cond:
ANY coll_bindings satisfies END
{
    $$ = expression.NewAny($2, $3)
}
|
SOME coll_bindings satisfies END
{
    $$ = expression.NewAny($2, $3)
}
|
EVERY coll_bindings satisfies END
{
    $$ = expression.NewEvery($2, $3)
}
|
ANY AND EVERY coll_bindings satisfies END
{
    $$ = expression.NewAnyEvery($4, $5)
}
|
SOME AND EVERY coll_bindings satisfies END
{
    $$ = expression.NewAnyEvery($4, $5)
}
;

coll_bindings:
coll_binding
{
    $$ = [$1];
}
|
coll_bindings COMMA coll_binding
{
    $1.push($3);
    $$ = $1;
}
;

coll_binding:
variable IN expr
{
    $$ = expression.NewSimpleBinding($1, $3)
}
|
variable WITHIN expr
{
    $$ = expression.NewBinding("", $1, $3, true)
}
|
variable COLON variable IN expr
{
    $$ = expression.NewBinding($1, $3, $5, false)
}
|
variable COLON variable WITHIN expr
{
    $$ = expression.NewBinding($1, $3, $5, true)
}
;

satisfies:
SATISFIES expr
{
    $$ = $2
}
;

collection_xform:
ARRAY expr FOR coll_bindings opt_when END
{
    $$ = expression.NewArray($2, $4, $5)
}
|
FIRST expr FOR coll_bindings opt_when END
{
    $$ = expression.NewFirst($2, $4, $5)
}
|
OBJECT expr COLON expr FOR coll_bindings opt_when END
{
    $$ = expression.NewObject($2, $4, $6, $7)
}
;


/*************************************************
 *
 * Parentheses and subquery
 *
 *************************************************/

paren_expr:
LPAREN expr RPAREN
{
    $$ = $2
}
|
LPAREN all_expr RPAREN
{
    $$ = $2
}
|
subquery_expr
{
    $$ = $1
}
;

subquery_expr:
LPAREN fullselect RPAREN
{
    $$ = algebra.NewSubquery($2);
}
;


/*************************************************
 *
 * Top-level expression input / parsing.
 *
 *************************************************/

expr_input:
expr
|
all_expr
;

all_expr:
all expr
{
    $$ = expression.NewAll($2, false)
}
|
all DISTINCT expr
{
    $$ = expression.NewAll($3, true)
}
|
DISTINCT expr
{
    $$ = expression.NewAll($2, true)
}
;