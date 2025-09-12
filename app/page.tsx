import Background from "./components/Background";
import Header from "./components/Header";
import Footer from "./components/Footer";

export default function Home() {
  return (
    <div className="relative min-h-screen text-white">
      <Background />
      <div className="relative z-10 flex flex-col min-h-screen">
        <Header />
        <main className="flex-grow flex flex-col items-center justify-center text-center px-4 my-24">
          <h1 className="text-5xl sm:text-6xl font-extrabold mb-4 leading-tight">
            Invest in Main Street.
            <br />
            <span className="text-cyan-400">Empower Local Shops.</span>
          </h1>
          
        </main>
        <Footer />
      </div>
    </div>
  );
}
