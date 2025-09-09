import React from "react";
import { FaBolt } from "react-icons/fa";

const Header = () => {
  return (
    <header className="w-full flex items-center justify-between p-4 sm:p-6">
      <div className="flex items-center gap-2">
        <FaBolt className="text-2xl text-cyan-400" />
        <h1 className="text-2xl font-bold text-white">Vitkara</h1>
      </div>
      
    </header>
  );
};

export default Header;
