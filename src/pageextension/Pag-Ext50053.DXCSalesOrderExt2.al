pageextension 50053 "DXCSalesOrderExt2" extends "Sales Order" 
{  
    layout
    {        
        addafter("DXC Inco Location")
        {
            field("DXC Freight Resource";"DXC Freight Resource")
            {
            }
        }
        
    }
}

