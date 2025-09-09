import React from "react";
import { FaTwitter, FaLinkedin, FaInstagram } from "react-icons/fa";

const Footer = () => {
  return (
    <footer className="w-full bg-black bg-opacity-50 text-white p-8">
      <div className="max-w-6xl mx-auto grid grid-cols-1 sm:grid-cols-3 gap-8">
        <div>
          <h3 className="text-lg font-bold mb-4">Vitkara</h3>
          <p className="text-gray-400">
            A micro-finance marketplace for small businesses.
          </p>
        </div>
        <div>
          <h3 className="text-lg font-bold mb-4">Quick Links</h3>
          <ul className="space-y-2">
            <li>
              <a href="#" className="text-gray-400 hover:text-white">
                About Us
              </a>
            </li>
            <li>
              <a href="#" className="text-gray-400 hover:text-white">
                Contact Us
              </a>
            </li>
            <li>
              <a href="#" className="text-gray-400 hover:text-white">
                Privacy policy
              </a>
            </li>
            <li>
              <a href="#" className="text-gray-400 hover:text-white">
                Terms and conditions
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
