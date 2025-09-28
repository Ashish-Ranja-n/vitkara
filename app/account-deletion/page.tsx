import React from 'react';
import Background from '../components/Background';
import Header from '../components/Header';
import Footer from '../components/Footer';

const AccountDeletion = () => {
  return (
    <div className="relative min-h-screen text-white">
      <Background />
      <div className="relative z-10 flex flex-col min-h-screen">
        <Header />
        <main className="flex-grow py-12 px-4 sm:px-6 lg:px-8">
          <div className="max-w-4xl mx-auto">
            <h1 className="text-3xl font-bold text-center text-white mb-8">
              VITKARA - Account Deletion
            </h1>

            <div className="bg-black/50 backdrop-blur-sm border border-cyan-400/20 rounded-lg p-6">
              <div className="space-y-4 text-gray-300">
                <div>
                  <h3 className="text-lg font-medium mb-2">Account Deletion Request</h3>
                  <p>If you wish to delete your VITKARA account, please follow the steps below:</p>
                </div>

                <div>
                  <h3 className="text-lg font-medium mb-2">1. Contact Support</h3>
                  <p>Send an email to support@vitkara.com with the subject "Account Deletion Request" and include your registered email address and phone number.</p>
                </div>

                <div>
                  <h3 className="text-lg font-medium mb-2">2. Verification</h3>
                  <p>Our team will verify your identity and process your request within 7-10 business days.</p>
                </div>

                <div>
                  <h3 className="text-lg font-medium mb-2">3. Data Retention</h3>
                  <p>Please note that some data may be retained for legal and regulatory purposes as required by law.</p>
                </div>

                <div>
                  <h3 className="text-lg font-medium mb-2">4. Confirmation</h3>
                  <p>You will receive a confirmation email once your account has been successfully deleted.</p>
                </div>

                <div>
                  <h3 className="text-lg font-medium mb-2">Contact Information</h3>
                  <p>For any questions, please contact us at support@vitkara.com or call +917301677612.</p>
                </div>
              </div>
            </div>
          </div>
        </main>
        <Footer />
      </div>
    </div>
  );
};

export default AccountDeletion;
