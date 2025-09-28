import React from 'react';
import Background from '../components/Background';
import Header from '../components/Header';
import Footer from '../components/Footer';

const PrivacyPolicy = () => {
  return (
    <div className="relative min-h-screen text-white">
      <Background />
      <div className="relative z-10 flex flex-col min-h-screen">
        <Header />
        <main className="flex-grow py-12 px-4 sm:px-6 lg:px-8">
          <div className="max-w-4xl mx-auto">
            <h1 className="text-3xl font-bold text-center text-white mb-8">
              VITKARA - Privacy Policy
            </h1>

            <div className="bg-black/50 backdrop-blur-sm border border-cyan-400/20 rounded-lg p-6">
              <div className="space-y-4 text-gray-300">
                <div>
                  <h3 className="text-lg font-medium mb-2">1. Introduction</h3>
                  <p>This Privacy Policy describes how VITKARA collects, uses, and protects your personal information when you use our platform.</p>
                </div>

                <div>
                  <h3 className="text-lg font-medium mb-2">2. Information We Collect</h3>
                  <p>We collect information you provide directly to us, such as when you register for an account, make investments, or contact us for support.</p>
                </div>

                <div>
                  <h3 className="text-lg font-medium mb-2">3. How We Use Your Information</h3>
                  <p>We use the information to provide, maintain, and improve our services, process transactions, and communicate with you.</p>
                </div>

                <div>
                  <h3 className="text-lg font-medium mb-2">4. Information Sharing</h3>
                  <p>We do not sell, trade, or otherwise transfer your personal information to third parties without your consent, except as described in this policy.</p>
                </div>

                <div>
                  <h3 className="text-lg font-medium mb-2">5. Data Security</h3>
                  <p>We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.</p>
                </div>

                <div>
                  <h3 className="text-lg font-medium mb-2">6. Contact Us</h3>
                  <p>If you have any questions about this Privacy Policy, please contact us at support@vitkara.com.</p>
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

export default PrivacyPolicy;
