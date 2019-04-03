tableextension 50034 "DXCSalesLineExt2" extends "Sales Line" //MyTargetTableId
{    

    var
        FreightLineDescriptionTxt : TextConst ENU='Freight Amount',ESM='Importe de flete',FRC='Montant des frais de transport',ENC='Freight Amount';

     [Scope('Personalization')]
    procedure DXCInsertFreightLine(var FreightAmount : Decimal);
    var
        SalesLine : Record "Sales Line";
        SalesSetup : Record "Sales & Receivables Setup";
        SalesHeader : Record "Sales Header";
        FreightAmountQuantity : Integer;
    begin
        
        if FreightAmount <= 0 then begin
          FreightAmount := 0;
          exit;
        end;

        // >> EC1.115
        FreightAmountQuantity := 1;
        // << EC1.115

        SalesSetup.GET;
        SalesSetup.TESTFIELD("Freight G/L Acc. No.");

        Rec.TESTFIELD("Document Type");
        Rec.TESTFIELD("Document No.");

        SalesLine.SETRANGE("Document Type","Document Type");
        SalesLine.SETRANGE("Document No.","Document No.");

        // >> EC1.115
        SalesLine.SETRANGE(Type,SalesLine.Type::"G/L Account");
        SalesLine.SETRANGE("No.",SalesSetup."Freight G/L Acc. No.");
        // "Quantity Shipped" will be equal to 0 until FreightAmount line successfully shipped
        SalesLine.SETRANGE("Quantity Shipped",0);
        IF SalesLine.FINDFIRST THEN BEGIN
          SalesLine.VALIDATE(Quantity,FreightAmountQuantity);
          SalesLine.VALIDATE("Unit Price",FreightAmount);
          SalesLine.MODIFY;
        END ELSE BEGIN
          SalesLine.SETRANGE(Type);
          SalesLine.SETRANGE("No.");
          SalesLine.SETRANGE("Quantity Shipped");
          SalesLine.FINDLAST;
          SalesLine."Line No." += 10000;
              
          SalesLine.INIT;
          // >> EC1.75
          SalesLine.SuspendStatusCheck(TRUE);
          // << EC1.75
          SalesLine.VALIDATE(Type,SalesLine.Type::"G/L Account");
          SalesLine.VALIDATE("No.",SalesSetup."Freight G/L Acc. No.");
          SalesLine.VALIDATE(Description,FreightLineDescriptionTxt);
          SalesLine.VALIDATE(Quantity,FreightAmountQuantity);
          // >> EC1.75
          SalesLine.VALIDATE("Qty. to Ship",1);
          SalesLine.VALIDATE("Qty. to Invoice",1); 
          // << EC1.75
          SalesLine.VALIDATE("Unit Price",FreightAmount);
          SalesLine.INSERT;
        end;
        // << EC1.115
    end;
    
}