/// Определение идентификатора
Class p6.rb.Definition Extends p6.Integrity [ ClassType = persistent ]
{

Index AkaIndex On Aka [ IdKey ];

Property Aka As %String;

Property Description As %String(MAXLEN = 200);

Property IsYellow As p6.dt.Boolean;

ClassMethod SaveData() As %Status
{
	set File=##class(%File).%New("c:\vssdb\"_$znspace_"\data\p6.rb.Definition.txt")
	$$$QuitOnError(File.Open("WSN"))
	&sql(declare cur1 cursor for 
		select Aka,Description,IsYellow 
		into :qAka,:qDescription,:qIsYellow
		from p6_rb.Definition
	)
	&sql(open cur1)
	for  {
		&sql(fetch cur1)
		quit:SQLCODE'=0
		do File.WriteLine(qAka_"*"_qIsYellow_"*"_qDescription)
	}
	&sql(close cur1)
	do File.Close()
	quit $$$OK
}

ClassMethod LoadData() As %Status
{
	$$$QuitOnError(..%KillExtent())
	set File=##class(%FileCharacterStream).%New()
	set File.Filename="c:\vssdb\"_$znspace_"\data\p6.rb.Definition.txt"
	set scAll=$$$OK
	set ^CacheTemp.IsLoad=1
	while 'File.AtEnd {
		set line=File.ReadLine()
		set Def=..%New()
		set Def.Aka=$piece(line,"*",1)
		set Def.IsYellow=$piece(line,"*",2)
		set Def.Description=$piece(line,"*",3,100)
		set scAll=$system.Status.AppendStatus(scAll,Def.Save())
	}
	kill ^CacheTemp.IsLoad
	quit scAll
}

Method OnAfterSave() As %Status
{
	if '$data(^CacheTemp.IsLoad) $$$QuitOnError(..SaveData())
	quit $$$OK
}

Storage Default
{
<Data name="DefinitionDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Description</Value>
</Value>
<Value name="3">
<Value>IsYellow</Value>
</Value>
</Data>
<DataLocation>^p6.rb.DefinitionD</DataLocation>
<DefaultData>DefinitionDefaultData</DefaultData>
<ExtentSize>100000</ExtentSize>
<IdLocation>^p6.rb.DefinitionD</IdLocation>
<IndexLocation>^p6.rb.DefinitionI</IndexLocation>
<StreamLocation>^p6.rb.DefinitionS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

