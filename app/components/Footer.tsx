import React from "react";
import Image from "next/image";
import { FaTwitter, FaLinkedin, FaInstagram } from "react-icons/fa";

const Footer = () => {
  return (
    <footer className="w-full bg-black bg-opacity-50 text-white p-8">
      <div className="max-w-6xl mx-auto grid grid-cols-1 sm:grid-cols-3 gap-8">
        <div>
          <h3 className="text-lg font-bold mb-4">Vitkara</h3>
          <p className="text-gray-400">
            An Investment Marketplace for Investors and Businesses.
          </p>
          <p className="text-gray-400 mt-2">Contact: +917301677612</p>
            <div className="mt-6 flex items-center space-x-3">
              <a
                href="https://github.com/Ashish-Ranja-n/vitkara/releases/download/v1.0.0/VITKARA.apk"
                target="_blank"
                rel="noopener noreferrer"
                aria-label="Get Vitkara on Google Play"
                className="inline-block transform hover:scale-105 transition-transform duration-200"
              >
                <Image
                  src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png"
                  alt="Get it on Google Play"
                  width={135}
                  height={40}
                  className="h-14 sm:h-16 w-auto"
                  unoptimized
                />
              </a>
              <a
                href="https://apps.apple.com/"
                target="_blank"
                rel="noopener noreferrer"
                aria-label="Download Vitkara on the App Store"
                className="inline-block transform hover:scale-105 transition-transform duration-200"
              >
                <Image
                  src="https://developer.apple.com/assets/elements/badges/download-on-the-app-store.svg"
                  alt="Download on the App Store"
                  width={120}
                  height={40}
                  className="h-10 sm:h-12 w-auto"
                  unoptimized
                />
              </a>
            </div>
        </div>
        <div>
          <h3 className="text-lg font-bold mb-4">Quick Links</h3>
          <ul className="space-y-2">
           
            <li>
              <a href="/terms" className="text-gray-400 hover:text-white">
                Terms & conditions
              </a>
            </li>
          </ul>
        </div>
        <div>
          <h3 className="text-lg font-bold mb-4">Follow Us</h3>
          <div className="flex space-x-4">
            <a href="#" className="text-gray-400 hover:text-white">
              <FaTwitter size={24} />
            </a>
            <a href="#" className="text-gray-400 hover:text-white">
              <FaLinkedin size={24} />
            </a>
            <a href="#" className="text-gray-400 hover:text-white">
              <FaInstagram size={24} />
            </a>
          </div>
        </div>
      </div>
      <div className="mt-8 border-t border-gray-800 pt-4 text-center text-gray-500">
        <p>&copy; {new Date().getFullYear()} Vitkara. All rights reserved.</p>
      </div>
    </footer>
  );
};

export default Footer;
