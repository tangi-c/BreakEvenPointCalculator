using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace BreakEvenPointCalculator
{
    public partial class Default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
                Session["Tab"] = 0;
        }

        protected override void OnPreRender(EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                base.OnPreRender(e);
                // if the page is reloaded with data resent, overwrites the default settings.
                ddlPRS_SelectedIndexChanged(ddlPRS, e);
                cbVat_CheckedChanged(cbVat, e);
                GetBep(tbTicketPrice, e);
            }
        }

        /// <summary>
        /// gets the data from the page and calls the function to calculate the break even point.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void GetBep(object sender, EventArgs e)
        {
            Validate();

            if (Page.IsValid)
            {
                double ticketPrice, guarantee, taxRatio, flatFee, percentage, minPRS, otherCosts ;
                if (double.TryParse(tbTicketPrice.Text, out ticketPrice) && double.TryParse(tbArtist.Text, out guarantee) && double.TryParse(tbCosts.Text, out otherCosts))
                {
                    // VAT
                    bool tax = cbVat.Checked;
                    if (tax)
                    {
                        double.TryParse(tbVat.Text, out taxRatio);
                        taxRatio = 1 + (taxRatio / 100);
                    }
                    else
                        taxRatio = 1;

                    //PRS
                    int prsType = int.Parse(ddlPRS.SelectedValue.ToString());
                    switch (prsType)
                    {
                        case 0: // No fee
                            flatFee = 0;
                            percentage = 0;
                            minPRS = 0;
                            break;
                        case 1: // flat fee
                            double.TryParse(tbPRS1.Text, out flatFee);
                            percentage = 0;
                            minPRS = 0;
                            break;
                        case 2: // percentage
                        default:
                            flatFee = 0;
                            double.TryParse(tbPRS1.Text, out percentage);
                            percentage = percentage / 100;
                            double.TryParse(tbPRS2.Text, out minPRS);
                            break;
                    }

                    int bep = Calculate(tax, prsType, ticketPrice, guarantee, taxRatio, flatFee, percentage, minPRS, otherCosts);
                    tbBEP.Text = bep.ToString();

                    int capacity;

                    if (int.TryParse(tbCapacity.Text, out capacity))
                    {
                        if ((bep >= capacity) || (bep < 0))
                            tbBEP.ForeColor = System.Drawing.Color.DarkRed;
                        else if (bep >= (capacity * 0.75))
                            tbBEP.ForeColor = System.Drawing.Color.DarkOrange;
                        else
                            tbBEP.ForeColor = System.Drawing.Color.DarkGreen;
                    }
                }
            }

            // bring the focus back to the control that called the function.
            WebControl c = sender as WebControl;
            if (Session["Tab"] != null)
            {
                if (Session["Tab"].ToString() == "1")
                {
                    foreach (WebControl ctrl in calculator.Controls.OfType<WebControl>())
                    {
                        if (ctrl.TabIndex == (c.TabIndex + 1))
                            ctrl.Focus();
                    }
                }
                else
                    c.Focus();
            }
            else
                c.Focus();

            Session["Tab"] = 0;
        }

        /// <summary>
        /// calculates the break even point.
        /// returns -1 when one of the inputs is not valid.
        /// </summary>
        /// <param name="tax"></param>
        /// <param name="prsType"></param>
        /// <param name="ticketPrice"></param>
        /// <param name="guarantee"></param>
        /// <param name="taxRatio"></param>
        /// <param name="flatFee"></param>
        /// <param name="percentage"></param>
        /// <param name="minPRS"></param>
        /// <param name="otherCosts"></param>
        /// <returns></returns>
        private int Calculate(bool tax, int prsType, double ticketPrice, double guarantee, double taxRatio, double flatFee, double percentage, double minPRS, double otherCosts)
        {
            // the values can't be negative and ticket price needs to be above zero (we don't want an infinite loop).
            if ((ticketPrice > 0) && (guarantee >= 0) && (flatFee >= 0) && (percentage >= 0) && (minPRS >= 0) && (otherCosts >=0))
            {
                int i = -1;
                double balance = -1;
                double grossTake, netTake, taxValue, prsAndVat;

                // calculate the balance with i tickets sold.
                // when the balance is positive, we have our BEP.
                while (balance <= 0)
                {
                    i++;
                    grossTake = ticketPrice * i;
                    netTake = grossTake / taxRatio;
                    taxValue = grossTake - netTake;

                    // get full amount of tax + PRS to be deducted
                    switch (prsType)
                    {
                        case 0: // no fee
                            if (tax)
                                prsAndVat = taxValue;
                            else
                                prsAndVat = 0;
                            break;
                        case 1: // flat fee
                            if (tax)
                                prsAndVat = taxValue + flatFee;
                            else
                                prsAndVat = flatFee;
                            break;
                        case 2: // percentage
                        default:
                            double percentageValue = netTake * percentage;
                            if (tax)
                            {
                                if (percentageValue >= minPRS)
                                    prsAndVat = taxValue + percentageValue;
                                else
                                    prsAndVat = taxValue + minPRS;
                            }
                            else
                            {
                                if (percentageValue >= minPRS)
                                    prsAndVat = percentageValue;
                                else
                                    prsAndVat = minPRS;
                            }
                            break;
                    }

                    // calculate balance.
                    balance = grossTake - prsAndVat - otherCosts - guarantee;
                }

                // i is the number of tickets that need to be sold to break even.
                return i;
            }
            else
                // if one of the input values is not valid, return -1.
                return -1;
        }

        /// <summary>
        /// rsponds to the dropdown list selection and calls the gets the new BEP.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void ddlPRS_SelectedIndexChanged(object sender, EventArgs e)
        {
            DropDownList ddl = sender as DropDownList;

            switch (int.Parse(ddl.SelectedValue.ToString()))
            {
                case 0: // No fee
                    lPRS1.Visible = false;
                    tbPRS1.Visible = false;
                    lPRS2.Visible = false;
                    tbPRS2.Visible = false;
                    break;
                case 1: // flat fee
                    lPRS1.Text = "Fee:";
                    lPRS1.Visible = true;
                    tbPRS1.Text = "0";
                    tbPRS1.Visible = true;
                    lPRS2.Visible = false;
                    tbPRS2.Visible = false;
                    break;
                case 2: // percentage
                default:
                    lPRS1.Text = "Percentage:";
                    lPRS1.Visible = true;
                    tbPRS1.Text = "3";
                    tbPRS1.Visible = true;
                    lPRS2.Visible = true;
                    tbPRS2.Text = "37";
                    tbPRS2.Visible = true;
                    break;
            }
            upCalculator.Update();
            GetBep(sender, e);
        }

        /// <summary>
        /// responds to the vat selection and gets the new BEP.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void cbVat_CheckedChanged(object sender, EventArgs e)
        {
            CheckBox cb = sender as CheckBox;

            if (cb.Checked)
            {
                lVat1.Visible = true;
                tbVat.Visible = true;
                lVat2.Visible = true;
            }
            else
            {
                lVat1.Visible = false;
                tbVat.Visible = false;
                lVat2.Visible = false;
            }

            upVat.Update();
            GetBep(sender, e);
        }

        /// <summary>
        /// Sets session["Tab"] when the last hit key is Tab.
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void SetSessionTab(object sender, EventArgs e)
        {
            Session["Tab"] = 1;
        }

        /// <summary>
        /// Resets sesion["Tab"].
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected void ResetSessionTab(object sender, EventArgs e)
        {
            Session["Tab"] = 0;
        }
    }
}