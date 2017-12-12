/// Ранг участника на дату
Class ent.Level Extends p6.Integrity [ ClassType = persistent ]
{

Property name As %String [ Required ];

Property shop As ent.Shop [ Required ];

}

