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
    begin
        //AOB-21
        if FreightAmount <= 0 then begin
          FreightAmount := 0;
          exit;
        end;

        SalesSetup.GET;
        SalesSetup.TESTFIELD("Freight G/L Acc. No.");

        Rec.TESTFIELD("Document Type");
        Rec.TESTFIELD("Document No.");

        SalesLine.SETRANGE("Document Type","Document Type");
        SalesLine.SETRANGE("Document No.","Document No.");

        SalesLine.SETRANGE(Type,SalesLine.Type::"G/L Account");
        SalesLine.SETRANGE("No.",SalesSetup."Freight G/L Acc. No.");
        // >> AOB-62
        SalesHeader.GET(Rec."Document Type",Rec."Document No.");
        IF (SalesHeader."DXC Freight Resource" <> '') THEN BEGIN  
          SalesLine.SETRANGE(Type,SalesLine.Type::Resource);
          SalesLine.SETRANGE("No.",SalesHeader."DXC Freight Resource");  
        END;
        // << AOB-62
        if SalesLine.FINDFIRST then begin
          //DXC
          SalesLine.SuspendStatusCheck(true);
          //
          SalesLine.VALIDATE(Quantity,1);
          //DXC
          SalesLine.VALIDATE("Qty. to Ship",1);
          SalesLine.VALIDATE("Qty. to Invoice",1);
          //
          SalesLine.VALIDATE("Unit Price",FreightAmount);
          SalesLine.MODIFY;
        end else begin
          SalesLine.SETRANGE(Type);
          SalesLine.SETRANGE("No.");
          SalesLine.FINDLAST;
          SalesLine."Line No." += 10000;

          SalesLine.INIT;
          //DXC
          SalesLine.SuspendStatusCheck(true);
          //
          // >> AOB-62
          IF SalesHeader."DXC Freight Resource" <> '' THEN BEGIN
            SalesLine.VALIDATE(Type,SalesLine.Type::Resource);
            SalesLine.VALIDATE("No.",SalesHeader."DXC Freight Resource");
          END ELSE BEGIN
          // << AOB-62
            SalesLine.VALIDATE(Type,SalesLine.Type::"G/L Account");
            SalesLine.VALIDATE("No.",SalesSetup."Freight G/L Acc. No.");
          // >> AOB-62
          END;
          // << AOB-62
          SalesLine.VALIDATE(Description,FreightLineDescriptionTxt);
          SalesLine.VALIDATE(Quantity,1);
          //DXC
          SalesLine.VALIDATE("Qty. to Ship",1);
          SalesLine.VALIDATE("Qty. to Invoice",1);
          //
          SalesLine.VALIDATE("Unit Price",FreightAmount);
          SalesLine.INSERT;
        end;
    end;
    
}