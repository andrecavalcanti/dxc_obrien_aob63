pageextension 50055 "DXCSalesOrderShipmentPageExt2" extends "Sales Order Shipment" //MyTargetPageId
{ 
    
    actions
    {
        addafter("P&ost")
        {
            action(DXCPost)
            {
                CaptionML = ENU='P&OST',
                            ESM='&Registrar',
                            FRC='Rep&orter',
                            ENC='P&ost';
                Ellipsis = true;
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'F9';
                ToolTipML = ENU='Finalize the document or journal by posting the amounts and quantities to the related accounts in your company books.',
                            ESM='Permite finalizar el documento o el diario registrando los importes y las cantidades en las cuentas relacionadas de los libros de su empresa.',
                            FRC='Finalisez le document ou le journal en reportant les montants et les quantités sur les comptes concernés dans la comptabilité de la compagnie.',
                            ENC='Finalize the document or journal by posting the amounts and quantities to the related accounts in your company books.';

                trigger OnAction();
                var
                    ApprovalsMgmt : Codeunit "Approvals Mgmt.";
                    PrepaymentMgt : Codeunit "Prepayment Mgt.";
                begin
                    //AOB-21
                    if ApprovalsMgmt.PrePostApprovalCheckSales(Rec) then begin
                        if PrepaymentMgt.TestSalesPrepayment(Rec) then
                        ERROR(STRSUBSTNO(Text001,"Document Type","No."));
                        // >> AOB-62
                        FreightAmount := GetFreightAmount;
                        // << AOB-62
                        if PrepaymentMgt.TestSalesPayment(Rec) then
                        ERROR(STRSUBSTNO(Text002,"Document Type","No."));

                        SalesLine.VALIDATE("Document Type","Document Type");
                        SalesLine.VALIDATE("Document No.","No.");
                        SalesLine.DXCInsertFreightLine(FreightAmount);
                        CODEUNIT.RUN(CODEUNIT::"Ship-Post (Yes/No)",Rec);
                        if "Shipping No." = '-1' then
                        ERROR('');
                    end;
                end;
            }

        }
        
    }

    var
        Text001 : TextConst ENU='There are non posted Prepayment Amounts on %1 %2.',ESM='No hay cantidades anticipo registradas en %1 %2.',FRC='Il y a des montants de paiement anticipé non reportés sur %1 %2.',ENC='There are non posted Prepayment Amounts on %1 %2.';
        Text002 : TextConst ENU='There are unpaid Prepayment Invoices related to %1 %2.',ESM='Existen facturas anticipo sin abonar relacionadas con %1 %2.',FRC='Il y a des factures pour paiement anticipé non payées associées à %1 %2.',ENC='There are unpaid Prepayment Invoices related to %1 %2.';
        SalesLine : Record "Sales Line";
        FreightAmount : Decimal;
     
         "---DXC Var---" : Integer;
        WeighDimDescription : Text;      

    trigger OnAfterGetRecord();
        begin            
            // >> AOB-11
            WeighDimDescription := DXCGetWeightDescription;
            // >> AOB-11
        end;

   
}
