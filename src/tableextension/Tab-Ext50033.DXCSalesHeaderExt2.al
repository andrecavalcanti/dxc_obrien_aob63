tableextension 50033 "DXCSalesHeaderExt2" extends "Sales Header" 
{ 
    fields
    {        
        field(50008;"DXC Freight Resource";Code[20])
        {
            Caption = 'Freight Resource';
            DataClassification = ToBeClassified;
            Description = 'AOB-63';
            TableRelation = Resource WHERE ("DXC Freight Resource"=CONST(true));
        }
    }
}

