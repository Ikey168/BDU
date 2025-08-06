import Image from 'next/image'
import { FaInstagram, FaTelegram, FaEnvelope } from 'react-icons/fa'

export default function Home() {
  return (
    <div className="flex flex-col min-h-screen">
      {/* Navbar */}
      <header className="sticky top-0 bg-white shadow">
        <nav className="container mx-auto flex items-center justify-between py-4 px-6 lg:px-0">
          <a href="/" className="flex items-center text-2xl font-bold">
            <Image src="/Logo_BDU.svg" alt="BDU Logo" width={40} height={40} />
            <span className="ml-2">Berlin Debating Union</span>
          </a>
          <ul className="hidden lg:flex space-x-8 text-lg">
            <li><a href="/events" className="hover:text-blue-500">Events</a></li>
            <li><a href="/membership" className="hover:text-blue-500">Mitgliedschaft</a></li>
            <li><a href="/training" className="hover:text-blue-500">Training</a></li>
            <li><a href="/resources" className="hover:text-blue-500">Ressourcen</a></li>
            <li><a href="/forum" className="hover:text-blue-500">Forum</a></li>
          </ul>
          <button className="lg:hidden p-2">
            {/* Mobile menu icon */}
            <svg className="w-6 h-6" fill="none" stroke="currentColor" strokeWidth={2} viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" d="M4 6h16M4 12h16M4 18h16" />
            </svg>
          </button>
        </nav>
      </header>

      {/* Hero Section */}
      <section id="hero" className="bg-blue-900 text-white py-24 flex-grow">
        <div className="container mx-auto flex flex-col md:flex-row items-center px-6 lg:px-0">
          <div className="md:w-1/2 text-center md:text-left mb-8 md:mb-0">
            <h1 className="text-5xl font-semibold">Berlin Debating Union</h1>
            <p className="mt-4 text-xl">Empowering university debaters since 1999</p>
          </div>
          <div className="md:w-1/2 flex justify-center md:justify-end">
            <Image
              src="/berlin_skyline.svg"
              alt="Berlin Skyline"
              width={400}
              height={200}
              className="rounded-lg shadow-lg"
            />
          </div>
        </div>
      </section>

      {/* Team Section */}
      <section id="team" className="py-16 bg-gray-100">
        <div className="container mx-auto px-6 lg:px-0">
          <h2 className="text-3xl font-light text-gray-800 mb-8 text-center">Unser Team</h2>
          {/* TODO: Team cards or accordion */}
        </div>
      </section>

      {/* Sponsors Section */}
      <section id="sponsors" className="py-16">
        <div className="container mx-auto px-6 lg:px-0">
          <h2 className="text-2xl font-semibold text-center mb-8">Unsere Partner</h2>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-8 items-center">
            <Image src="/partners/lotto-berlin.png" alt="Lotto Berlin" width={200} height={100} />
            <Image src="/partners/sag-was.png" alt="Sag Was" width={200} height={100} />
            {/* Weitere Logos hier */}
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-gray-200 py-10">
        <div className="container mx-auto flex flex-col md:flex-row justify-between px-6 lg:px-0">
          <div className="mb-6 md:mb-0">
            <h3 className="text-xl font-semibold">Berlin Debating Union</h3>
            <div className="flex space-x-4 mt-2">
              <a href="https://www.instagram.com/berlindebatingunion/"><FaInstagram size={24} /></a>
              <a href="https://t.me/berlindebatingunion"><FaTelegram size={24} /></a>
              <a href="mailto:kontakt@debating.de"><FaEnvelope size={24} /></a>
            </div>
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-8">
            <div>
              <h4 className="font-bold mb-2">Verein</h4>
              <ul className="space-y-1">
                <li><a href="/about" className="text-gray-700 hover:underline">Über uns</a></li>
                <li><a href="/club" className="text-gray-700 hover:underline">Clubleben</a></li>
                <li><a href="/debates" className="text-gray-700 hover:underline">Debatten</a></li>
              </ul>
            </div>
            <div>
              <h4 className="font-bold mb-2">Debattieren</h4>
              <ul className="space-y-1">
                <li><a href="/debattant" className="text-gray-700 hover:underline">Als Redner*in</a></li>
                <li><a href="/juror" className="text-gray-700 hover:underline">Als Juror*in</a></li>
              </ul>
            </div>
            <div>
              <h4 className="font-bold mb-2">Kontakt</h4>
              <ul className="space-y-1">
                <li><a href="/imprint" className="text-gray-700 hover:underline">Impressum</a></li>
                <li><a href="/privacy" className="text-gray-700 hover:underline">Datenschutz</a></li>
              </ul>
            </div>
          </div>
        </div>
      </footer>
    </div>
  )
}
