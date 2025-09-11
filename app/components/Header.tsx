import React from "react";
import { FaBolt } from "react-icons/fa";

const Header = () => {
  return (
    <header className="w-full flex items-center justify-between p-4 sm:p-6">
      <div className="flex items-center gap-2">
        <img src="/vitkara_logo2.jpg" alt="Vitkara Logo" className=" h-[25px] sm:h-[50px] w-auto" />
      </div>
      
    </header>
  );
};

export default Header;
