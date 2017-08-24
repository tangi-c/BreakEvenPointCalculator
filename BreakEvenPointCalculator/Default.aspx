<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="BreakEvenPointCalculator.Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Break even point calculator</title>
    <!-- CSS files -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.0.0-alpha.6/css/bootstrap.min.css" rel='stylesheet' type='text/css' />
    <link href="Css/style.css" rel='stylesheet' type='text/css' />

    <!-- JavaScript files -->
    <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.0.0-alpha.6/js/bootstrap.min.js"></script>

</head>
<body>
    <h1 class="centre"><a href="Default.aspx">Break even point calculator</a></h1>
    <form id="calculator" class="centre" runat="server">
        <div>
            <asp:ScriptManager ID="smCalculator" EnablePageMethods="true" runat="server">
            </asp:ScriptManager>

            <div class="row">
                <div class="col-lg-6">
                    <fieldset>
                        <legend>Tickets</legend>
                        <table>
                            <tr>
                                <td class="left-width">
                                    <asp:Label ID="lTicketPrice" Text="Face value:" runat="server" />
                                </td>
                                <td>
                                    <asp:TextBox ID="tbTicketPrice" Type="number" Text="0" ToolTip="Enter the ticket face value here" OnTextChanged="GetBep" CssClass="form-control" AutoPostBack="true" runat="server" />
                                    <asp:RequiredFieldValidator ID="rfvTicket" ControlToValidate="tbTicketPrice" EnableClientScript="false" Display="Dynamic" ErrorMessage="A ticket price is needed." runat="server" />
                                    <asp:RegularExpressionValidator ID="revTicket" ControlToValidate="tbTicketPrice" EnableClientScript="false" ValidationExpression="^\d{0,10}(\.\d{0,2})?$" Display="Dynamic" ErrorMessage="This needs to be a positive number" runat="server" />
                                </td>
                            </tr>
                        </table>
                    </fieldset>
                </div>

                <div class="col-lg-6">
                    <fieldset>
                        <legend>VAT</legend>
                        <table>
                            <tr>
                                <td class="left-width">
                                    <asp:Label ID="lVat" Text="VAT registered: " runat="server" />
                                </td>
                                <td>
                                    <asp:CheckBox ID="cbVat" Checked="true" ToolTip="Tick if you are VAT registered" OnCheckedChanged="cbVat_CheckedChanged" CssClass="Checkbox" AutoPostBack="true" runat="server" />
                                </td>
                            </tr>
                            <asp:UpdatePanel ID="upVat" UpdateMode="Conditional" runat="server">
                                <ContentTemplate>
                                    <tr>
                                        <td class="left-width">
                                            <asp:Label ID="lVat1" Text="VAT rate:" runat="server" />
                                        </td>
                                        <td>
                                            <asp:TextBox ID="tbVat" Type="number" Text="20" ToolTip="Enter the ticket face value here" OnTextChanged="GetBep" CssClass="form-control" AutoPostBack="true" runat="server" />
                                            <asp:RegularExpressionValidator ID="revVat" ControlToValidate="tbVat" EnableClientScript="false" ValidationExpression="^\d{0,10}(\.\d{0,2})?$" Display="Dynamic" ErrorMessage="This needs to be a positive number" runat="server" />
                                        </td>
                                        <td>
                                            <asp:Label ID="lVat2" Text="%" runat="server" />
                                        </td>
                                    </tr>
                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </table>
                    </fieldset>
                </div>
            </div>

            <div class="row">
                <div class="col-lg-6">
                    <fieldset>
                        <legend>PRS</legend>
                        <table>
                            <tr>
                                <td class="left-width">
                                    <asp:Label ID="lPRS" Text="PRS type:" runat="server" />
                                </td>
                                <td>
                                    <asp:DropDownList ID="ddlPRS" ToolTip="Select the PRS type" OnSelectedIndexChanged="ddlPRS_SelectedIndexChanged" CssClass="form-control" AutoPostBack="true" runat="server">
                                        <asp:ListItem Value="0">No PRS</asp:ListItem>
                                        <asp:ListItem Value="1">Flat fee</asp:ListItem>
                                        <asp:ListItem Value="2" Selected="True">Percentage</asp:ListItem>
                                    </asp:DropDownList>
                                </td>
                            </tr>
                            <asp:UpdatePanel ID="upCalculator" UpdateMode="Conditional" runat="server">
                                <ContentTemplate>
                                    <tr>
                                        <td class="left-width">
                                            <asp:Label ID="lPRS1" Text="Percentage:" runat="server" />
                                        </td>
                                        <td>
                                            <asp:TextBox ID="tbPRS1" Type="number" Text="3" OnTextChanged="GetBep" CssClass="form-control" AutoPostBack="true" runat="server" />
                                            <asp:RegularExpressionValidator ID="revPRS1" ControlToValidate="tbPRS1" EnableClientScript="false" ValidationExpression="^\d{0,10}(\.\d{0,2})?$" Display="Dynamic" ErrorMessage="This needs to be a positive number" runat="server" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="left-width">
                                            <asp:Label ID="lPRS2" Text="minimum (net): " runat="server" />
                                        </td>
                                        <td>
                                            <asp:TextBox ID="tbPRS2" Type="number" Text="39" ToolTip="Enter the minimum PRS amount (net)" OnTextChanged="GetBep" CssClass="form-control" AutoPostBack="true" runat="server" />
                                            <asp:RegularExpressionValidator ID="revPRS2" ControlToValidate="tbPRS2" EnableClientScript="false" ValidationExpression="^\d{0,10}(\.\d{0,2})?$" Display="Dynamic" ErrorMessage="This needs to be a positive number" runat="server" />
                                        </td>
                                    </tr>
                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </table>
                    </fieldset>
                </div>

                <div class="col-lg-6">
                    <fieldset>
                        <legend>Costs</legend>
                        <table>
                            <tr>
                                <td class="left-width">
                                    <asp:Label ID="lArtist" Text="Artist guarantee:" runat="server" />
                                </td>
                                <td>
                                    <asp:TextBox ID="tbArtist" Type="number" Text="0" ToolTip="Enter the artist minimum fee" OnTextChanged="GetBep" CssClass="form-control" AutoPostBack="true" runat="server" />
                                    <asp:RegularExpressionValidator ID="revArtist" ControlToValidate="tbArtist" EnableClientScript="false" ValidationExpression="^\d{0,10}(\.\d{0,2})?$" Display="Dynamic" ErrorMessage="This needs to be a positive number" runat="server" />
                                </td>
                            </tr>
                            <tr>
                                <td class="left-width">
                                    <asp:Label ID="lCosts" Text="All other costs:" runat="server" />
                                </td>
                                <td>
                                    <asp:TextBox ID="tbCosts" Type="number" Text="0" ToolTip="Enter the total of all other costs" OnTextChanged="GetBep" CssClass="form-control" AutoPostBack="true" runat="server" />
                                    <asp:RegularExpressionValidator ID="revCosts" ControlToValidate="tbCosts" EnableClientScript="false" ValidationExpression="^\d{0,10}(\.\d{0,2})?$" Display="Dynamic" ErrorMessage="This needs to be a positive number" runat="server" />
                                </td>
                            </tr>
                        </table>
                    </fieldset>
                </div>
            </div>

            <div class="row justify-content-center">
                <div class="col-lg-6">
                    <fieldset>
                        <legend>Tickets to break even</legend>
                        <table>
                            <tr>
                                <td class="left-width">
                                    <asp:Label ID="lCapacity" Text="Capacity:" runat="server" />
                                </td>
                                <td>
                                    <asp:TextBox ID="tbCapacity" Type="number" Text="0" ToolTip="Enter the venue capacity" OnTextChanged="GetBep" CssClass="form-control" AutoPostBack="true" runat="server" />
                                    <asp:RegularExpressionValidator ID="revCapacity" ControlToValidate="tbCapacity" EnableClientScript="false" ValidationExpression="^\d{0,10}(\.\d{0,2})?$" Display="Dynamic" ErrorMessage="This needs to be a positive number" runat="server" />
                                </td>
                                <td>
                                    <asp:Label ID="lCapacity2" Text="(Optional)" runat="server" />
                                </td>
                            </tr>
                            <tr>
                                <td class="left-width">
                                    <asp:Label ID="lBEP" Text="Break even point:" runat="server" />
                                </td>
                                <td>
                                    <asp:TextBox ID="tbBEP" ReadOnly="true" CssClass="form-control" runat="server" />
                                </td>
                            </tr>
                        </table>
                    </fieldset>
                </div>
            </div>
        </div>
    </form>

</body>
</html>
