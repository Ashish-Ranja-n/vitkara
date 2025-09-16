import React from 'react';

const TermsAndConditions = () => {
  return (
    <div className="min-h-screen bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-4xl mx-auto">
        <h1 className="text-3xl font-bold text-center text-gray-900 mb-8">
          VITKARA - Terms & Conditions
        </h1>

        {/* Merchant Terms & Conditions */}
        <div className="bg-white shadow-lg rounded-lg p-6 mb-8">
          <h2 className="text-2xl font-semibold text-gray-800 mb-6">
            Merchant Terms & Conditions
          </h2>

          <div className="space-y-4 text-gray-700">
            <div>
              <h3 className="text-lg font-medium mb-2">1. Introduction</h3>
              <p>These Terms & Conditions ("Agreement") govern the relationship between VITKARA ("Company") and the Merchant ("You") who receives funds for business growth. By accepting funds, you accept all terms below.</p>
            </div>

            <div>
              <h3 className="text-lg font-medium mb-2">2. Funding Structure</h3>
              <ul className="list-disc list-inside space-y-1">
                <li>Merchants receive an agreed Principal Amount from VITKARA.</li>
                <li>Repayment = Principal + agreed ROI of X% (Return on Investment).</li>
                <li>Repayment mode: Daily deduction via UPI/QR code at an agreed percentage of daily sales (10–30%) until full repayment is completed.</li>
              </ul>
            </div>

            <div>
              <h3 className="text-lg font-medium mb-2">3. Repayment Rules</h3>
              <ul className="list-disc list-inside space-y-1">
                <li>Daily Deduction Mandatory: Merchant must ensure the daily UPI/QR sale percentage is available for automatic deduction.</li>
                <li>Cash Limitation: Merchant may take a maximum of 20% of total sales in cash; at least 80% of total sales must be processed through UPI/QR to ensure repayment tracking.</li>
                <li>Early Repayment: Allowed anytime without penalty.</li>
                <li>Delayed Repayment: Any delay immediately reduces the Merchant's credit rating on VITKARA and may trigger penalties.</li>
              </ul>
            </div>

            <div>
              <h3 className="text-lg font-medium mb-2">4. Obligations of Merchant</h3>
              <ul className="list-disc list-inside space-y-1">
                <li>Funds to be used strictly for business purposes.</li>
                <li>Maintain daily sales records and submit reports to VITKARA upon request.</li>
                <li>Provide accurate KYC, PAN, GST, and bank details.</li>
                <li>Cooperate with VITKARA during inspections, audits, or verification.</li>
                <li>Notify VITKARA immediately of any significant drop in sales or closure of business.</li>
              </ul>
            </div>

            <div>
              <h3 className="text-lg font-medium mb-2">5. Restrictions</h3>
              <p>Merchants are strictly prohibited from:</p>
              <ul className="list-disc list-inside space-y-1">
                <li>Accepting more than 20% of daily sales in cash.</li>
                <li>Diverting funds to unrelated purposes or third parties.</li>
                <li>Providing misleading information about sales or business operations.</li>
                <li>Closing or moving the business without settling VITKARA dues.</li>
              </ul>
            </div>

            <div>
              <h3 className="text-lg font-medium mb-2">6. Default & Penalty</h3>
              <ul className="list-disc list-inside space-y-1">
                <li>Immediate Blacklisting: Merchant will be blacklisted from future funding on first major default.</li>
                <li>Penalty Charges: A penalty of up to X% of overdue amounts may be charged for delays.</li>
                <li>Legal Action: VITKARA may initiate legal recovery under Indian Contract Act & Negotiable Instruments Act.</li>
                <li>Third-Party Recovery Agents: VITKARA reserves the right to engage recovery agencies if dues remain unpaid.</li>
                <li>Credit Bureau Reporting: Merchant default information may be reported to credit bureaus and online databases.</li>
              </ul>
            </div>

            <div>
              <h3 className="text-lg font-medium mb-2">7. Security & Collateral</h3>
              <ul className="list-disc list-inside space-y-1">
                <li>VITKARA may require post-dated cheques, personal guarantees, or security documents.</li>
                <li>Merchant agrees to sign necessary agreements or security instruments if requested.</li>
              </ul>
            </div>

            <div>
              <h3 className="text-lg font-medium mb-2">8. Risk & Liability</h3>
              <ul className="list-disc list-inside space-y-1">
                <li>VITKARA does not act as a bank or NBFC.</li>
                <li>Merchant acknowledges repayment obligations regardless of business performance.</li>
                <li>Merchant agrees not to dispute repayment unless fraud is proven.</li>
              </ul>
            </div>

            <div>
              <h3 className="text-lg font-medium mb-2">9. Governing Law & Dispute Resolution</h3>
              <ul className="list-disc list-inside space-y-1">
                <li>Governed by the laws of India.</li>
                <li>Disputes resolved via arbitration in Sitamarhi, Bihar, or local courts if required.</li>
              </ul>
            </div>

            <div>
              <h3 className="text-lg font-medium mb-2">10. Acceptance</h3>
              <p>By accepting funds from VITKARA, the Merchant confirms they have read, understood, and agreed to these Terms.</p>
            </div>
          </div>
        </div>

        {/* Investor Terms & Conditions */}
        <div className="bg-white shadow-lg rounded-lg p-6 mb-8">
          <h2 className="text-2xl font-semibold text-gray-800 mb-6">
            Investor Terms & Conditions
          </h2>

          <div className="space-y-4 text-gray-700">
            <div>
              <h3 className="text-lg font-medium mb-2">1. Introduction</h3>
              <p>These Terms & Conditions ("Agreement") govern the relationship between VITKARA ("Company") and the Investor ("You") who provides funds for business growth of Merchants onboarded on the VITKARA platform.</p>
            </div>

            <div>
              <h3 className="text-lg font-medium mb-2">2. Investment Structure</h3>
              <ul className="list-disc list-inside space-y-1">
                <li>Investors provide an agreed principal amount to VITKARA to be deployed with Merchants.</li>
                <li>Investors earn an agreed ROI of X% (Return on Investment) on the invested amount.</li>
                <li>Payouts are collected from Merchants via daily deductions (10–30% of their daily sales) until full repayment of Principal + ROI is completed.</li>
              </ul>
            </div>

            <div>
              <h3 className="text-lg font-medium mb-2">3. Payout Terms</h3>
              <ul className="list-disc list-inside space-y-1">
                <li>Payouts to Investors occur on a daily basis after VITKARA receives repayments from Merchants.</li>
                <li>VITKARA will transfer collected repayments (principal + ROI) to the Investor's registered bank account daily.</li>
                <li>Early withdrawals of investment may be allowed subject to Company policy.</li>
              </ul>
            </div>

            <div>
              <h3 className="text-lg font-medium mb-2">4. Obligations of Investor</h3>
              <ul className="list-disc list-inside space-y-1">
                <li>Provide accurate KYC, PAN, and bank details for compliance.</li>
                <li>Understand and accept that ROI (X%) is not guaranteed by VITKARA but depends on Merchant performance and repayment.</li>
                <li>Authorize VITKARA to manage collection and distribution on their behalf.</li>
              </ul>
            </div>

            <div>
              <h3 className="text-lg font-medium mb-2">5. Risk & Liability</h3>
              <ul className="list-disc list-inside space-y-1">
                <li>VITKARA acts only as a facilitator between Investor and Merchant.</li>
                <li>VITKARA does not provide any guaranteed return unless explicitly stated in writing.</li>
                <li>In case of Merchant default, VITKARA will take recovery measures but cannot guarantee full recovery.</li>
              </ul>
            </div>

            <div>
              <h3 className="text-lg font-medium mb-2">6. Default & Dispute Handling</h3>
              <ul className="list-disc list-inside space-y-1">
                <li>In the event a Merchant defaults, VITKARA will initiate legal action and recovery processes.</li>
                <li>VITKARA may apply recovered amounts proportionately among affected Investors.</li>
              </ul>
            </div>

            <div>
              <h3 className="text-lg font-medium mb-2">7. Governing Law & Dispute Resolution</h3>
              <ul className="list-disc list-inside space-y-1">
                <li>Governed by the laws of India.</li>
                <li>Disputes resolved via arbitration in Sitamarhi, Bihar, or local courts if required.</li>
              </ul>
            </div>

            <div>
              <h3 className="text-lg font-medium mb-2">8. Acceptance</h3>
              <p>By investing funds through VITKARA, you confirm you have read, understood, and agreed to these Terms.</p>
            </div>
          </div>
        </div>

        {/* Platform Terms & Conditions */}
        <div className="bg-white shadow-lg rounded-lg p-6">
          <h2 className="text-2xl font-semibold text-gray-800 mb-6">
            Platform Terms & Conditions
          </h2>

          <div className="space-y-4 text-gray-700">
            <div>
              <h3 className="text-lg font-medium mb-2">1. Introduction</h3>
              <p>These Terms & Conditions ("Agreement") govern your access to and use of the VITKARA platform, website, and mobile applications ("Platform"). By using VITKARA, you agree to comply with these Terms.</p>
            </div>

            <div>
              <h3 className="text-lg font-medium mb-2">2. Scope of Services</h3>
              <ul className="list-disc list-inside space-y-1">
                <li>VITKARA is a technology platform connecting Investors with Merchants for revenue-based funding.</li>
                <li>VITKARA is not a bank, NBFC, or financial institution. It only facilitates transactions between Merchants and Investors.</li>
                <li>All investments and repayments are handled as per agreed terms between Merchants, Investors, and VITKARA.</li>
              </ul>
            </div>

            <div>
              <h3 className="text-lg font-medium mb-2">3. Eligibility</h3>
              <ul className="list-disc list-inside space-y-1">
                <li>You must be at least 18 years old and legally capable of entering into a contract under Indian law.</li>
                <li>Accurate KYC and identity verification is mandatory for both Merchants and Investors.</li>
              </ul>
            </div>

            <div>
              <h3 className="text-lg font-medium mb-2">4. User Responsibilities</h3>
              <ul className="list-disc list-inside space-y-1">
                <li>Provide accurate and complete information during registration.</li>
                <li>Maintain confidentiality of your account credentials.</li>
                <li>Use the platform only for lawful business and investment activities.</li>
                <li>Promptly update any change in your KYC, bank details, or contact information.</li>
              </ul>
            </div>

            <div>
              <h3 className="text-lg font-medium mb-2">5. Financial Transactions</h3>
              <ul className="list-disc list-inside space-y-1">
                <li>VITKARA facilitates payments via UPI/QR, bank transfers, and other permitted modes.</li>
                <li>All transactions are processed securely. However, VITKARA does not guarantee the performance or repayment ability of Merchants.</li>
                <li>Any ROI or repayment is based on the terms agreed between Investor and Merchant and is not guaranteed by VITKARA.</li>
              </ul>
            </div>

            <div>
              <h3 className="text-lg font-medium mb-2">6. Fees & Commission</h3>
              <ul className="list-disc list-inside space-y-1">
                <li>VITKARA may charge a service fee or commission on transactions as per its pricing policy.</li>
                <li>Fees may be deducted from Merchant payouts or Investor returns before disbursement.</li>
              </ul>
            </div>

            <div>
              <h3 className="text-lg font-medium mb-2">7. Risk Disclosure</h3>
              <ul className="list-disc list-inside space-y-1">
                <li>Investments involve risk including possible loss of principal.</li>
                <li>VITKARA is not responsible for losses due to Merchant default, market changes, or unforeseen circumstances.</li>
                <li>VITKARA will take reasonable steps for collection and dispute resolution but cannot guarantee full recovery.</li>
              </ul>
            </div>

            <div>
              <h3 className="text-lg font-medium mb-2">8. Prohibited Activities</h3>
              <p>Users must not:</p>
              <ul className="list-disc list-inside space-y-1">
                <li>Provide false or misleading information.</li>
                <li>Use the platform for money laundering or illegal activities.</li>
                <li>Circumvent VITKARA to deal directly with Merchants/Investors without platform consent.</li>
              </ul>
            </div>

            <div>
              <h3 className="text-lg font-medium mb-2">9. Termination of Access</h3>
              <ul className="list-disc list-inside space-y-1">
                <li>VITKARA may suspend or terminate user accounts for violations of these Terms or applicable laws.</li>
                <li>Pending obligations must still be fulfilled even after termination.</li>
              </ul>
            </div>

            <div>
              <h3 className="text-lg font-medium mb-2">10. Privacy Policy</h3>
              <ul className="list-disc list-inside space-y-1">
                <li>VITKARA collects and processes personal data as per its Privacy Policy.</li>
                <li>By using the platform, you consent to this data collection and processing.</li>
              </ul>
            </div>

            <div>
              <h3 className="text-lg font-medium mb-2">11. Governing Law & Dispute Resolution</h3>
              <ul className="list-disc list-inside space-y-1">
                <li>Governed by the laws of India.</li>
                <li>Disputes will be resolved via arbitration in Sitamarhi, Bihar, or by local courts as applicable.</li>
              </ul>
            </div>

            <div>
              <h3 className="text-lg font-medium mb-2">12. Acceptance</h3>
              <p>By using VITKARA, you confirm you have read, understood, and agreed to these Terms.</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default TermsAndConditions;
