import Background from "./components/Background";
import Header from "./components/Header";
import Footer from "./components/Footer";
import { FaArrowRight } from "react-icons/fa";

export default function Home() {
  return (
    <div className="relative min-h-screen text-white">
      <Background />
      <div className="relative z-10 flex flex-col min-h-screen">
        <Header />
        <main className="flex-grow flex flex-col items-center justify-center text-center px-4 my-16">
          <h1 className="text-5xl sm:text-6xl font-extrabold mb-4 leading-tight">
            Invest in Main Street.
            <br />
            <span className="text-cyan-400">Empower Local Shops.</span>
          </h1>
          <p className="text-md font-semibold sm:text-xl max-w-3xl mx-auto text-gray-300 mb-8">
            Vitkara is a micro-finance marketplace that funds small local shops by connecting them with everyday investors.
          </p>
          <button className="bg-cyan-400 text-black font-bold py-3 px-8 rounded-full text-lg hover:bg-cyan-300 transition-transform transform hover:scale-105 flex items-center gap-2">
            <span>Explore Opportunities</span>
            <FaArrowRight />
          </button>
        </main>
        <Footer />
      </div>
    </div>
  );
}
