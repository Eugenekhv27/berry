/// Ранг участника на дату
Class ent.City Extends p6.Integrity [ ClassType = persistent ]
{

Property name As %String(MAXLEN = 200) [ Required ];

Property shop As ent.Shop [ Required ];

}

