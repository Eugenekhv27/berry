/// Ранг участника на дату
Class ent.BuyerAbcGroup Extends p6.Integrity [ ClassType = persistent ]
{

Property buyer As ent.Buyer [ Required ];

Property onDate As p6.dt.Date [ Required ];

Property groupName As %String;

}

