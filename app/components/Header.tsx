'use client';
import React, { useState, useEffect } from "react";
import Image from "next/image";

const Header = () => {
  const [isScrolled, setIsScrolled] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 0);
    };

    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  return (
    <header className="w-full flex items-center justify-between p-4 sm:p-6 sticky top-0">
      <div className={`flex items-center gap-2 transition-all duration-300 ${isScrolled ? 'backdrop-blur-lg bg-cyan-400/10 rounded-md' : ''}`}>
        <Image src="/vitkara_logo3.png" alt="Vitkara Logo" width={50} height={50} className="h-[25px] sm:h-[50px] w-auto" />
      </div>

    </header>
  );
};

export default Header;
