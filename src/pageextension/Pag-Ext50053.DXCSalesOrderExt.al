pageextension 50053 "DXCSalesOrderExt" extends "Sales Order" 
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

