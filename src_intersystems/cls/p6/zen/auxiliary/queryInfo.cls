/// Возможность филтров с вхождением без учета регистра
Class p6.zen.auxiliary.queryInfo Extends %ZEN.Auxiliary.QueryInfo
{

/// Utility method: construct a (very simple) SQL statement based on the
/// specifications contains within this object's properties.
/// The resulting query is placed within the <property>queryText</property> property.
Method %CreateSQL(pComputeRowCount As %Boolean = 1, pInfo As %ZEN.Auxiliary.QueryInfo) As %Status
{
	#; Set TOP = rows+1 so we can tell if there are *more* rows
	Set tTOP = $S(+..rows=0:"",1:" TOP "_(..rows+1)_" ")
	Set tSELECT = ""
	Set tFROM = ..tableName
	Set tWHERE = ""

	#; determine if there is an ORDER BY
	Set tORDERBY = ..orderByClause
	If (..sortColumn '= "") {
		#; use or prepend sortColumn if defined
		Set tORDERBY = ..sortColumn _ $S(..sortOrder="desc":" desc",1:"") _ $S(tORDERBY="":"",1:",") _ tORDERBY
	}

	#; determine if there is a GROUP BY
	Set tGROUPBY = ..groupByClause

	#; build SELECT list from columns
	Set n = $O(..columns(""))
	While (n '= "") {
		If ($G(..columns(n))'="") {
			#; process column expression, if present
			Set tColExpr = $G(..columnExpression(..columns(n)))
			Set tColExpr = $S(tColExpr'="":tColExpr_" ",1:"") _ ..columns(n)
			Set tSELECT = tSELECT _ $S(tSELECT="":"",1:",") _ tColExpr
		}
		Set n = $O(..columns(n))
	}
	
	#; If no columns, make a simple query based on ID
	#; and columnName if defined
	If (tSELECT = "") {
		Set tSELECT = "%ID" _ $S(..columnName'="":","_..columnName,1:"")
	}

	#; Build (part of) WHERE clause based on filters
	Set key = $O(..filters(""))
	While (key '= "") {
		If ($G(..filters(key))'="") {
			Set type = $G(..filterTypes(key))
			Set field = $S($G(..columnExpression(key))'="":..columnExpression(key),1:key)

			#; strip off field alias, if any
			Set:field[" " field = $P(field," ",1)

			If (type = "query") {
				Set field = key
			}

			Set op = $G(..filterOps(key))
			Set:op="" op = "%STARTSWITH"
			#; Test for non-binary operators
			Set clause = ""
			If (op = "IN") {
				#; build IN list
				Set inlist = ""
				For p=1:1:$L(..filters(key),",") {
					Set inlist = inlist _ $S(inlist="":"",1:",") _ ..QuoteSQL($P(..filters(key),",",p),type)
				}
				If (inlist '= "") {
					Set clause = field _ " IN (" _ inlist _")"
				}
			}
			ElseIf (op = "%CONTAINS") {
				#; build CONTAINS list
				Set inlist = ""
				For p=1:1:$L(..filters(key),",") {
					Set inlist = inlist _ $S(inlist="":"",1:",") _ ..QuoteSQL($P(..filters(key),",",p),type)
				}
				If (inlist '= "") {
					Set clause = field _ " %CONTAINS (" _ inlist _")"
				}
			}
			ElseIf (op = "BETWEEN") {
				#; get terms
				Set t1 = $P(..filters(key),",",1)
				Set t2 = $P(..filters(key),",",2)
				
				If ((t1 '= "") && (t2 '= "")) {
					Set clause = field _ " BETWEEN " _ ..QuoteSQL(t1,type) _ " AND " _ ..QuoteSQL(t2,type)
				}
				ElseIf (t1 '= "") {
					#; use >= t1
					Set clause = field _ " >= " _ ..QuoteSQL(t1,type)
				}
				ElseIf (t2 '= "") {
					#; use <= t2
					Set clause = field _ " <= " _ ..QuoteSQL(t2,type)
				}
				Else {
					#; ignore
				}
			}
			;+++++++p6
			ElseIf (op = "[NOCASE") {
				Set clause = "UCASE("_ field _ ") [ UCASE("_ ..QuoteSQL(..filters(key),type)_")"
			}
			;-------p6
			Else {
				Set clause = field _ " "_ op _" " _ ..QuoteSQL(..filters(key),type)
			}

			Set:clause'="" tWHERE = tWHERE _ $S(tWHERE="":"",1:" AND ") _ clause
		}
		Set key = $O(..filters(key))
	}

	#; combine WHERE with whereClause
	If (..whereClause '= "") {
		If (tWHERE = "") {
			Set tWHERE = ..whereClause
		}
		Else {
			Set tWHERE = tWHERE _ " AND (" _ ..whereClause _ ")"
		}
	}

	If tFROM = "" {
		Quit $$$ERROR($$$GeneralError,"Missing FROM clause")
	}

	If tSELECT = "" {
		Quit $$$ERROR($$$GeneralError,"Missing SELECT list")
	}

	Set sql = "SELECT " _ tTOP _ " " _ tSELECT _ " FROM " _ tFROM
	Set:tWHERE'="" sql = sql _ " WHERE " _tWHERE

	If (tGROUPBY'="") {
		Set sql = sql _ " GROUP BY " _tGROUPBY
	}

	If (tORDERBY'="") {
		Set sql = sql _ " ORDER BY " _tORDERBY
	}

	Set ..queryText = sql

	#; find rowCount
	If (pComputeRowCount) {
		#; execute query to get rowCount of all results
		Set sql2 = "SELECT COUNT(*) As C FROM " _ tFROM
		Set:tWHERE'="" sql2 = sql2 _ " WHERE " _tWHERE

		Set tRS2 = ##class(%ResultSet).%New()
		Set tSC = tRS2.Prepare(sql2)
		If $$$ISERR(tSC) Quit tSC

		#; Execute based on number of parms
		Set tParmCount = tRS2.GetParamCount()
		If (tParmCount = 0) {
			Set tSC = tRS2.%Execute()
		}
		ElseIf (tParmCount = 1) {
			Set tSC = tRS2.%Execute($G(pInfo.parms(1)))
		}
		Else {
			#; use Xecute
			New %sc,%info,%rs
			Set %info = pInfo
			Set %rs = tRS2
			Set x = "S %sc = %rs.%Execute("
			For n = 1:1:tParmCount {
				Set x = x _ $S(n>1:",",1:"") _ "$G(%info.parms("_n_"))"
			}
			Set x = x _ ")"
			X x

			Set tSC = %sc
			Kill %sc,%info,%rs
		}

		If $$$ISERR(tSC) Quit tSC

		If (tRS2.%Next()) {		
			Set ..rowCount = $G(tRS2.Data("C"))
		}
	}

	Quit $$$OK
}

}

