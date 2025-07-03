export default function Home() {
  return (
    <div className="flex flex-col items-center justify-center min-h-screen p-8 bg-gradient-to-br from-blue-50 to-indigo-100">
      <div className="text-center">
        <h1 className="text-4xl font-bold text-gray-900 mb-4">
          🚀 Your Next.js App is Running!
        </h1>
        <p className="text-lg text-gray-600 mb-8">
          Successfully deployed in a microVM in Poridhi Cloud
        </p>
        <div className="bg-white rounded-lg shadow-md p-6 max-w-md mx-auto">
          <h2 className="text-2xl font-semibold text-gray-800 mb-4">
            System Status
          </h2>
          <div className="space-y-2 text-left">
            <div className="flex justify-between">
              <span className="text-gray-600">Docker:</span>
              <span className="text-green-600 font-semibold">✅ Working</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-600">Systemd:</span>
              <span className="text-green-600 font-semibold">✅ Working</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-600">Next.js:</span>
              <span className="text-green-600 font-semibold">✅ Working</span>
            </div>
            <div className="flex justify-between">
              <span className="text-gray-600">Port Mapping:</span>
              <span className="text-green-600 font-semibold">✅ Working</span>
            </div>
          </div>
        </div>
        <p className="text-sm text-gray-500 mt-6">
          Edit app/page.tsx to customize this page
        </p>
      </div>
    </div>
  );
}
