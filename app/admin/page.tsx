'use client';

import { useEffect, useState, useCallback } from 'react';
import { useRouter } from 'next/navigation';

interface Stats {
  totalInvestors: number;
  totalShops: number;
  totalAdmins: number;
}

interface Shop {
  _id: string;
  name: string;
  email: string;
  location?: string;
  owner: string;
  totalRaised: number;
  activeCampaigns: number;
  verified: boolean;
  createdAt: string;
}

interface Campaign {
  _id: string;
  title: string;
  shopId: { name: string; email: string };
  targetAmount: number;
  currentAmount: number;
  status: string;
  createdAt: string;
  description?: string;
  expectedROI?: number;
  minInvestment?: number;
  maxInvestment?: number;
}

interface Notification {
  id: string;
  type: 'success' | 'error' | 'info';
  message: string;
}

export default function AdminDashboard() {
  const [stats, setStats] = useState<Stats | null>(null);
  const [campaigns, setCampaigns] = useState<Campaign[]>([]);
  const [shops, setShops] = useState<Shop[]>([]);
  const [loading, setLoading] = useState(true);
  const [campaignsLoading, setCampaignsLoading] = useState(true);
  const [shopsLoading, setShopsLoading] = useState(true);
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [showCreateShopModal, setShowCreateShopModal] = useState(false);
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [formData, setFormData] = useState({
    shopId: '',
    title: '',
    description: '',
    targetAmount: '',
    minInvestment: '',
    maxInvestment: '',
    expectedROI: '',
    duration: '',
    dailyRepaymentPercentage: '',
    endDate: '',
  });
  const [shopFormData, setShopFormData] = useState({
    name: '',
    email: '',
    location: '',
    owner: '',
    avgUpiTransactions: '',
  });
  const [formErrors, setFormErrors] = useState<Record<string, string>>({});
  const [shopFormErrors, setShopFormErrors] = useState<Record<string, string>>({});
  const [submitting, setSubmitting] = useState(false);
  const router = useRouter();

  // Notification system
  const addNotification = useCallback((type: 'success' | 'error' | 'info', message: string) => {
    const id = Date.now().toString();
    setNotifications(prev => [...prev, { id, type, message }]);
    setTimeout(() => {
      setNotifications(prev => prev.filter(n => n.id !== id));
    }, 5000);
  }, []);

  const removeNotification = useCallback((id: string) => {
    setNotifications(prev => prev.filter(n => n.id !== id));
  }, []);

  // Fetch data with individual loading states
  useEffect(() => {
    const fetchData = async () => {
      try {
        // Fetch all data in parallel
        const [statsRes, campaignsRes, shopsRes] = await Promise.all([
          fetch('/api/admin/stats'),
          fetch('/api/admin/campaigns'),
          fetch('/api/admin/shops')
        ]);

        // Handle stats
        if (statsRes.ok) {
          const statsData = await statsRes.json();
          setStats(statsData);
        } else if (statsRes.status === 401) {
          router.push('/admin/login');
          return;
        } else {
          console.error('Stats API error:', statsRes.status);
          addNotification('error', 'Failed to load statistics');
        }

        // Handle campaigns
        if (campaignsRes.ok) {
          const campaignsData = await campaignsRes.json();
          setCampaigns(campaignsData.campaigns || []);
        } else {
          console.error('Campaigns API error:', campaignsRes.status);
          addNotification('error', 'Failed to load campaigns');
        }

        // Handle shops
        if (shopsRes.ok) {
          const shopsData = await shopsRes.json();
          setShops(shopsData.shops || []);
        } else {
          console.error('Shops API error:', shopsRes.status);
          addNotification('error', 'Failed to load shops');
        }

      } catch (error) {
        console.error('Error fetching data:', error);
        addNotification('error', 'Failed to load dashboard data');
      }

      // Always set loading to false (moved outside try-catch)
      setLoading(false);
      setCampaignsLoading(false);
      setShopsLoading(false);
    };

    // Add a timeout to force loading to complete even if APIs are slow
    const timeoutId = setTimeout(() => {
      setLoading(false);
      setCampaignsLoading(false);
      setShopsLoading(false);
    }, 10000); // 10 second timeout

    fetchData();

    return () => clearTimeout(timeoutId);
  }, [router, addNotification]);

  // Form validation
  const validateCampaignForm = () => {
    const errors: Record<string, string> = {};

    if (!formData.shopId) errors.shopId = 'Please select a shop';
    if (!formData.title.trim()) errors.title = 'Campaign title is required';
    if (!formData.description.trim()) errors.description = 'Description is required';
    if (!formData.targetAmount || parseFloat(formData.targetAmount) < 1000) {
      errors.targetAmount = 'Target amount must be at least ₹1,000';
    }
    if (!formData.minInvestment || parseFloat(formData.minInvestment) < 100) {
      errors.minInvestment = 'Minimum investment must be at least ₹100';
    }
    if (!formData.maxInvestment || parseFloat(formData.maxInvestment) < parseFloat(formData.minInvestment || '0')) {
      errors.maxInvestment = 'Maximum investment must be greater than minimum';
    }
    if (parseFloat(formData.maxInvestment || '0') > parseFloat(formData.targetAmount || '0')) {
      errors.maxInvestment = 'Maximum investment cannot exceed target amount';
    }
    if (!formData.expectedROI || parseFloat(formData.expectedROI) <= 0) {
      errors.expectedROI = 'Expected ROI must be greater than 0';
    }
    if (!formData.duration || parseInt(formData.duration) < 30) {
      errors.duration = 'Duration must be at least 30 days';
    }
    if (!formData.dailyRepaymentPercentage || parseFloat(formData.dailyRepaymentPercentage) <= 0) {
      errors.dailyRepaymentPercentage = 'Daily repayment percentage is required';
    }
    if (!formData.endDate) errors.endDate = 'Expected end date is required';

    setFormErrors(errors);
    return Object.keys(errors).length === 0;
  };

  const validateShopForm = () => {
    const errors: Record<string, string> = {};

    if (!shopFormData.name.trim()) errors.name = 'Shop name is required';
    if (!shopFormData.email.trim()) errors.email = 'Email is required';
    if (!shopFormData.owner.trim()) errors.owner = 'Owner name is required';

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (shopFormData.email && !emailRegex.test(shopFormData.email)) {
      errors.email = 'Please enter a valid email address';
    }

    setShopFormErrors(errors);
    return Object.keys(errors).length === 0;
  };

  const handleCreateCampaign = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!validateCampaignForm()) {
      addNotification('error', 'Please fix the form errors before submitting');
      return;
    }

    setSubmitting(true);

    try {
      const res = await fetch('/api/admin/campaigns', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(formData),
      });

      if (res.ok) {
        addNotification('success', 'Campaign created successfully!');
        setShowCreateModal(false);
        setFormData({
          shopId: '',
          title: '',
          description: '',
          targetAmount: '',
          minInvestment: '',
          maxInvestment: '',
          expectedROI: '',
          duration: '',
          dailyRepaymentPercentage: '',
          endDate: '',
        });
        setFormErrors({});
        // Refresh campaigns list
        const campaignsRes = await fetch('/api/admin/campaigns');
        if (campaignsRes.ok) {
          const campaignsData = await campaignsRes.json();
          setCampaigns(campaignsData.campaigns);
        }
      } else {
        const error = await res.json();
        addNotification('error', error.message || 'Failed to create campaign');
      }
    } catch (error) {
      console.error('Error creating campaign:', error);
      addNotification('error', 'An error occurred while creating the campaign');
    } finally {
      setSubmitting(false);
    }
  };

  const handleCreateShop = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!validateShopForm()) {
      addNotification('error', 'Please fix the form errors before submitting');
      return;
    }

    setSubmitting(true);

    try {
      const res = await fetch('/api/admin/shops', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(shopFormData),
      });

      if (res.ok) {
        addNotification('success', 'Shop created successfully!');
        setShowCreateShopModal(false);
        setShopFormData({
          name: '',
          email: '',
          location: '',
          owner: '',
          avgUpiTransactions: '',
        });
        setShopFormErrors({});
        // Refresh shops list
        const shopsRes = await fetch('/api/admin/shops');
        if (shopsRes.ok) {
          const shopsData = await shopsRes.json();
          setShops(shopsData.shops);
        }
      } else {
        const error = await res.json();
        addNotification('error', error.message || 'Failed to create shop');
      }
    } catch (error) {
      console.error('Error creating shop:', error);
      addNotification('error', 'An error occurred while creating the shop');
    } finally {
      setSubmitting(false);
    }
  };

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleStatusChange = async (campaignId: string, newStatus: string) => {
    try {
      const res = await fetch('/api/admin/campaigns', {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          campaignId,
          status: newStatus,
        }),
      });

      if (res.ok) {
        addNotification('success', 'Campaign status updated successfully!');

        // Update the campaign in the local state
        setCampaigns(prevCampaigns =>
          prevCampaigns.map(campaign =>
            campaign._id === campaignId
              ? { ...campaign, status: newStatus }
              : campaign
          )
        );
      } else {
        const error = await res.json();
        addNotification('error', error.message || 'Failed to update campaign status');
      }
    } catch (error) {
      console.error('Error updating campaign status:', error);
      addNotification('error', 'An error occurred while updating the campaign status');
    }
  };

  const handleShopInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    setShopFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  // Loading skeleton component
  const LoadingSkeleton = ({ className = "" }: { className?: string }) => (
    <div className={`animate-pulse bg-gray-200 rounded ${className}`}></div>
  );

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-100">
        <header className="bg-white shadow">
          <div className="max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8">
            <LoadingSkeleton className="h-8 w-64" />
          </div>
        </header>
        <main className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
          <div className="px-4 py-6 sm:px-0">
            <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3">
              {[1, 2, 3].map((i) => (
                <div key={i} className="bg-white overflow-hidden shadow rounded-lg">
                  <div className="p-5">
                    <div className="flex items-center">
                      <LoadingSkeleton className="w-8 h-8 rounded-md" />
                      <div className="ml-5 w-0 flex-1">
                        <LoadingSkeleton className="h-4 w-20 mb-2" />
                        <LoadingSkeleton className="h-6 w-12" />
                      </div>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </main>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-100">
      {/* Notification System */}
      <div className="fixed top-4 right-4 z-50 space-y-2">
        {notifications.map((notification) => (
          <div
            key={notification.id}
            className={`max-w-sm p-4 rounded-md shadow-lg border-l-4 ${
              notification.type === 'success'
                ? 'bg-green-50 border-green-400 text-green-800'
                : notification.type === 'error'
                ? 'bg-red-50 border-red-400 text-red-800'
                : 'bg-blue-50 border-blue-400 text-blue-800'
            }`}
          >
            <div className="flex items-center justify-between">
              <p className="text-sm font-medium">{notification.message}</p>
              <button
                onClick={() => removeNotification(notification.id)}
                className="ml-4 text-gray-400 hover:text-gray-600"
              >
                <span className="text-lg">&times;</span>
              </button>
            </div>
          </div>
        ))}
      </div>

      <header className="bg-white shadow">
        <div className="max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between">
            <h1 className="text-3xl font-bold text-gray-900">Admin Dashboard</h1>
            <div className="flex items-center space-x-4">
              <div className="text-sm text-gray-500">
                Welcome back, Admin
              </div>
              <button
                onClick={() => router.push('/admin/login')}
                className="text-sm text-gray-600 hover:text-gray-900"
              >
                Logout
              </button>
            </div>
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
        {/* Stats Cards */}
        <div className="px-4 py-6 sm:px-0">
          <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3">
            <div className="bg-white overflow-hidden shadow rounded-lg">
              <div className="p-5">
                <div className="flex items-center">
                  <div className="flex-shrink-0">
                    <div className="w-8 h-8 bg-blue-500 rounded-md flex items-center justify-center">
                      <span className="text-white font-bold">I</span>
                    </div>
                  </div>
                  <div className="ml-5 w-0 flex-1">
                    <dl>
                      <dt className="text-sm font-medium text-gray-500 truncate">
                        Total Investors
                      </dt>
                      <dd className="text-lg font-medium text-gray-900">
                        {stats?.totalInvestors || 0}
                      </dd>
                    </dl>
                  </div>
                </div>
              </div>
            </div>

            <div className="bg-white overflow-hidden shadow rounded-lg">
              <div className="p-5">
                <div className="flex items-center">
                  <div className="flex-shrink-0">
                    <div className="w-8 h-8 bg-green-500 rounded-md flex items-center justify-center">
                      <span className="text-white font-bold">S</span>
                    </div>
                  </div>
                  <div className="ml-5 w-0 flex-1">
                    <dl>
                      <dt className="text-sm font-medium text-gray-500 truncate">
                        Total Shops
                      </dt>
                      <dd className="text-lg font-medium text-gray-900">
                        {stats?.totalShops || 0}
                      </dd>
                    </dl>
                  </div>
                </div>
              </div>
            </div>

            <div className="bg-white overflow-hidden shadow rounded-lg">
              <div className="p-5">
                <div className="flex items-center">
                  <div className="flex-shrink-0">
                    <div className="w-8 h-8 bg-purple-500 rounded-md flex items-center justify-center">
                      <span className="text-white font-bold">A</span>
                    </div>
                  </div>
                  <div className="ml-5 w-0 flex-1">
                    <dl>
                      <dt className="text-sm font-medium text-gray-500 truncate">
                        Total Admins
                      </dt>
                      <dd className="text-lg font-medium text-gray-900">
                        {stats?.totalAdmins || 0}
                      </dd>
                    </dl>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Shop Management Section */}
        <div className="px-4 py-6 sm:px-0">
          <div className="bg-white shadow rounded-lg">
            <div className="px-4 py-5 sm:p-6">
              <div className="flex justify-between items-center mb-6">
                <h3 className="text-lg leading-6 font-medium text-gray-900">
                  Shop Management
                </h3>
                <button
                  onClick={() => setShowCreateShopModal(true)}
                  className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
                >
                  Create Shop
                </button>
              </div>

              {/* Shops List */}
              <div className="space-y-4">
                {shopsLoading ? (
                  // Loading skeletons for shops
                  Array.from({ length: 3 }).map((_, i) => (
                    <div key={i} className="border rounded-lg p-4">
                      <div className="animate-pulse">
                        <div className="flex justify-between items-start">
                          <div className="flex-1">
                            <LoadingSkeleton className="h-5 w-48 mb-2" />
                            <LoadingSkeleton className="h-4 w-64 mb-2" />
                            <LoadingSkeleton className="h-4 w-40" />
                          </div>
                          <LoadingSkeleton className="h-6 w-20 rounded-full" />
                        </div>
                      </div>
                    </div>
                  ))
                ) : shops.length === 0 ? (
                  <div className="text-center py-12">
                    <div className="mx-auto h-12 w-12 text-gray-400">
                      <svg fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
                      </svg>
                    </div>
                    <h3 className="mt-2 text-sm font-medium text-gray-900">No shops</h3>
                    <p className="mt-1 text-sm text-gray-500">Get started by creating your first shop.</p>
                    <div className="mt-6">
                      <button
                        onClick={() => setShowCreateShopModal(true)}
                        className="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500"
                      >
                        <svg className="-ml-1 mr-2 h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
                        </svg>
                        Create Shop
                      </button>
                    </div>
                  </div>
                ) : (
                  shops.map((shop) => (
                    <div key={shop._id} className="border rounded-lg p-4 hover:shadow-md transition-shadow duration-200">
                      <div className="flex justify-between items-start">
                        <div className="flex-1">
                          <div className="flex items-center space-x-3">
                            <div className="flex-shrink-0">
                              <div className="w-10 h-10 bg-green-100 rounded-lg flex items-center justify-center">
                                <span className="text-green-600 font-semibold text-sm">
                                  {shop.name.charAt(0).toUpperCase()}
                                </span>
                              </div>
                            </div>
                            <div>
                              <h4 className="text-lg font-medium text-gray-900">{shop.name}</h4>
                              <p className="text-sm text-gray-600">{shop.email}</p>
                            </div>
                          </div>
                          <div className="mt-3 grid grid-cols-2 gap-4 text-sm">
                            <div>
                              <span className="text-gray-500">Owner:</span>
                              <span className="ml-1 text-gray-900">{shop.owner}</span>
                            </div>
                            <div>
                              <span className="text-gray-500">Raised:</span>
                              <span className="ml-1 text-gray-900">₹{shop.totalRaised.toLocaleString()}</span>
                            </div>
                            <div>
                              <span className="text-gray-500">Campaigns:</span>
                              <span className="ml-1 text-gray-900">{shop.activeCampaigns}</span>
                            </div>
                            {shop.location && (
                              <div>
                                <span className="text-gray-500">Location:</span>
                                <span className="ml-1 text-gray-900">{shop.location}</span>
                              </div>
                            )}
                          </div>
                        </div>
                        <div className="flex items-center space-x-2">
                          <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                            shop.verified ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800'
                          }`}>
                            {shop.verified ? 'Verified' : 'Unverified'}
                          </span>
                        </div>
                      </div>
                    </div>
                  ))
                )}
              </div>
            </div>
          </div>
        </div>

        {/* Campaign Management Section */}
        <div className="px-4 py-6 sm:px-0">
          <div className="bg-white shadow rounded-lg">
            <div className="px-4 py-5 sm:p-6">
              <div className="flex justify-between items-center mb-6">
                <h3 className="text-lg leading-6 font-medium text-gray-900">
                  Investment Campaigns
                </h3>
                <button
                  onClick={() => setShowCreateModal(true)}
                  className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
                >
                  Create Campaign
                </button>
              </div>

              {/* Campaigns List */}
              <div className="space-y-4">
                {campaignsLoading ? (
                  // Loading skeletons for campaigns
                  Array.from({ length: 3 }).map((_, i) => (
                    <div key={i} className="border rounded-lg p-4">
                      <div className="animate-pulse">
                        <div className="flex justify-between items-start">
                          <div className="flex-1">
                            <LoadingSkeleton className="h-5 w-48 mb-2" />
                            <LoadingSkeleton className="h-4 w-64 mb-2" />
                            <LoadingSkeleton className="h-4 w-40" />
                          </div>
                          <LoadingSkeleton className="h-6 w-20 rounded-full" />
                        </div>
                      </div>
                    </div>
                  ))
                ) : campaigns.length === 0 ? (
                  <div className="text-center py-12">
                    <div className="mx-auto h-12 w-12 text-gray-400">
                      <svg fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                      </svg>
                    </div>
                    <h3 className="mt-2 text-sm font-medium text-gray-900">No campaigns</h3>
                    <p className="mt-1 text-sm text-gray-500">Get started by creating your first investment campaign.</p>
                    <div className="mt-6">
                      <button
                        onClick={() => setShowCreateModal(true)}
                        className="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
                      >
                        <svg className="-ml-1 mr-2 h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
                        </svg>
                        Create Campaign
                      </button>
                    </div>
                  </div>
                ) : (
                  campaigns.map((campaign) => (
                    <div key={campaign._id} className="border rounded-lg p-4 hover:shadow-md transition-shadow duration-200">
                      <div className="flex justify-between items-start">
                        <div className="flex-1">
                          <div className="flex items-center space-x-3">
                            <div className="flex-shrink-0">
                              <div className="w-10 h-10 bg-indigo-100 rounded-lg flex items-center justify-center">
                                <span className="text-indigo-600 font-semibold text-sm">
                                  {campaign.title.charAt(0).toUpperCase()}
                                </span>
                              </div>
                            </div>
                            <div>
                              <h4 className="text-lg font-medium text-gray-900">{campaign.title}</h4>
                              <p className="text-sm text-gray-600">{campaign.shopId.name}</p>
                            </div>
                          </div>
                          <div className="mt-3 grid grid-cols-2 gap-4 text-sm">
                            <div>
                              <span className="text-gray-500">Target:</span>
                              <span className="ml-1 text-gray-900">₹{campaign.targetAmount.toLocaleString()}</span>
                            </div>
                            <div>
                              <span className="text-gray-500">Current:</span>
                              <span className="ml-1 text-gray-900">₹{campaign.currentAmount.toLocaleString()}</span>
                            </div>
                            <div>
                              <span className="text-gray-500">Progress:</span>
                              <span className="ml-1 text-gray-900">
                                {campaign.targetAmount > 0
                                  ? Math.round((campaign.currentAmount / campaign.targetAmount) * 100)
                                  : 0}%
                              </span>
                            </div>
                            <div>
                              <span className="text-gray-500">Investors:</span>
                              <span className="ml-1 text-gray-900">
                                {/* This would need to be calculated from investments */}
                                0
                              </span>
                            </div>
                          </div>
                        </div>
                        <div className="flex items-center space-x-2">
                          <select
                            value={campaign.status}
                            onChange={(e) => handleStatusChange(campaign._id, e.target.value)}
                            className={`text-xs font-semibold rounded-full px-2 py-1 border-0 focus:ring-2 focus:ring-indigo-500 focus:outline-none transition-all duration-200 ${
                              campaign.status === 'active' ? 'bg-green-100 text-green-800' :
                              campaign.status === 'funded' ? 'bg-blue-100 text-blue-800' :
                              campaign.status === 'repaying' ? 'bg-yellow-100 text-yellow-800' :
                              campaign.status === 'completed' ? 'bg-gray-100 text-gray-800' :
                              'bg-red-100 text-red-800'
                            }`}
                          >
                            <option value="draft">Draft</option>
                            <option value="active">Active</option>
                            <option value="funded">Funded</option>
                            <option value="repaying">Repaying</option>
                            <option value="completed">Completed</option>
                            <option value="defaulted">Defaulted</option>
                          </select>
                        </div>
                      </div>
                    </div>
                  ))
                )}
              </div>
            </div>
          </div>
        </div>
      </main>

      {/* Create Campaign Modal */}
      {showCreateModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 overflow-y-auto h-full w-full z-50 flex items-center justify-center p-4">
          <div className="relative bg-white w-full max-w-4xl mx-auto rounded-xl shadow-2xl max-h-[90vh] overflow-y-auto">
            {/* Header */}
            <div className="px-8 py-6 border-b border-gray-200 bg-gradient-to-r from-indigo-50 to-blue-50">
              <div className="flex justify-between items-center">
                <div>
                  <h3 className="text-2xl font-bold text-gray-900">Create Investment Campaign</h3>
                  <p className="text-sm text-gray-600 mt-1">Set up a new investment opportunity for your shop</p>
                </div>
                <button
                  onClick={() => setShowCreateModal(false)}
                  className="text-gray-400 hover:text-gray-600 transition-colors duration-200 p-2 hover:bg-gray-100 rounded-full"
                  aria-label="Close modal"
                >
                  <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>
            </div>

            <form onSubmit={handleCreateCampaign} className="px-8 py-8">
              <div className="space-y-8">
                {/* Basic Information Section */}
                <div className="bg-gray-50 rounded-lg p-6">
                  <h4 className="text-lg font-semibold text-gray-900 mb-4 flex items-center">
                    <svg className="w-5 h-5 mr-2 text-indigo-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                    Basic Information
                  </h4>

                  <div className="grid grid-cols-1 gap-6">
                    <div>
                      <label htmlFor="shopId" className="block text-sm font-semibold text-gray-700 mb-2">
                        Select Shop <span className="text-red-500">*</span>
                      </label>
                      <select
                        id="shopId"
                        name="shopId"
                        value={formData.shopId}
                        onChange={handleInputChange}
                        className={`block w-full px-4 py-3 border-2 rounded-lg shadow-sm text-sm transition-all duration-200 bg-white text-gray-900 ${
                          formErrors.shopId
                            ? 'border-red-300 focus:ring-red-500 focus:border-red-500 bg-red-50'
                            : 'border-gray-300 focus:ring-indigo-500 focus:border-indigo-500 hover:border-indigo-400'
                        }`}
                        required
                      >
                        <option value="">Choose a shop for this campaign</option>
                        {shops.map((shop) => (
                          <option key={shop._id} value={shop._id}>
                            {shop.name} - {shop.email}
                          </option>
                        ))}
                      </select>
                      {formErrors.shopId && (
                        <p className="mt-2 text-sm text-red-600 flex items-center">
                          <svg className="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                            <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clipRule="evenodd" />
                          </svg>
                          {formErrors.shopId}
                        </p>
                      )}
                    </div>

                    <div>
                      <label htmlFor="title" className="block text-sm font-semibold text-gray-700 mb-2">
                        Campaign Title <span className="text-red-500">*</span>
                      </label>
                      <input
                        type="text"
                        id="title"
                        name="title"
                        value={formData.title}
                        onChange={handleInputChange}
                        className={`block w-full px-4 py-3 border-2 rounded-lg shadow-sm text-sm transition-all duration-200 text-gray-900 placeholder-gray-500 ${
                          formErrors.title
                            ? 'border-red-300 focus:ring-red-500 focus:border-red-500 bg-red-50'
                            : 'border-gray-300 focus:ring-indigo-500 focus:border-indigo-500 hover:border-indigo-400'
                        }`}
                        placeholder="Enter an attractive campaign title"
                        required
                      />
                      {formErrors.title && (
                        <p className="mt-2 text-sm text-red-600 flex items-center">
                          <svg className="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                            <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clipRule="evenodd" />
                          </svg>
                          {formErrors.title}
                        </p>
                      )}
                    </div>

                    <div>
                      <label htmlFor="description" className="block text-sm font-semibold text-gray-700 mb-2">
                        Campaign Description <span className="text-red-500">*</span>
                      </label>
                      <textarea
                        id="description"
                        name="description"
                        rows={4}
                        value={formData.description}
                        onChange={handleInputChange}
                        className="block w-full px-4 py-3 border-2 border-gray-300 rounded-lg shadow-sm focus:ring-indigo-500 focus:border-indigo-500 text-sm transition-all duration-200 text-gray-900 placeholder-gray-500 hover:border-indigo-400 resize-none"
                        placeholder="Describe your investment opportunity, business model, and expected returns..."
                        required
                      />
                    </div>
                  </div>
                </div>

                {/* Financial Details Section */}
                <div className="bg-blue-50 rounded-lg p-6">
                  <h4 className="text-lg font-semibold text-gray-900 mb-4 flex items-center">
                    <svg className="w-5 h-5 mr-2 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                    Financial Details
                  </h4>

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div>
                      <label htmlFor="targetAmount" className="block text-sm font-semibold text-gray-700 mb-2">
                        Target Amount (₹) <span className="text-red-500">*</span>
                      </label>
                      <div className="relative">
                        <span className="absolute left-3 top-3 text-gray-500">₹</span>
                        <input
                          type="number"
                          id="targetAmount"
                          name="targetAmount"
                          value={formData.targetAmount}
                          onChange={handleInputChange}
                          className={`block w-full pl-8 pr-4 py-3 border-2 rounded-lg shadow-sm text-sm transition-all duration-200 text-gray-900 placeholder-gray-500 ${
                            formErrors.targetAmount
                              ? 'border-red-300 focus:ring-red-500 focus:border-red-500 bg-red-50'
                              : 'border-gray-300 focus:ring-blue-500 focus:border-blue-500 hover:border-blue-400'
                          }`}
                          placeholder="10000"
                          min="1000"
                          required
                        />
                      </div>
                      {formErrors.targetAmount && (
                        <p className="mt-2 text-sm text-red-600 flex items-center">
                          <svg className="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                            <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clipRule="evenodd" />
                          </svg>
                          {formErrors.targetAmount}
                        </p>
                      )}
                    </div>

                    <div>
                      <label htmlFor="minInvestment" className="block text-sm font-semibold text-gray-700 mb-2">
                        Minimum Investment (₹) <span className="text-red-500">*</span>
                      </label>
                      <div className="relative">
                        <span className="absolute left-3 top-3 text-gray-500">₹</span>
                        <input
                          type="number"
                          id="minInvestment"
                          name="minInvestment"
                          value={formData.minInvestment}
                          onChange={handleInputChange}
                          className={`block w-full pl-8 pr-4 py-3 border-2 rounded-lg shadow-sm text-sm transition-all duration-200 text-gray-900 placeholder-gray-500 ${
                            formErrors.minInvestment
                              ? 'border-red-300 focus:ring-red-500 focus:border-red-500 bg-red-50'
                              : 'border-gray-300 focus:ring-blue-500 focus:border-blue-500 hover:border-blue-400'
                          }`}
                          placeholder="100"
                          min="100"
                          required
                        />
                      </div>
                      {formErrors.minInvestment && (
                        <p className="mt-2 text-sm text-red-600 flex items-center">
                          <svg className="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                            <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clipRule="evenodd" />
                          </svg>
                          {formErrors.minInvestment}
                        </p>
                      )}
                    </div>

                    <div>
                      <label htmlFor="maxInvestment" className="block text-sm font-semibold text-gray-700 mb-2">
                        Maximum Investment (₹) <span className="text-red-500">*</span>
                      </label>
                      <div className="relative">
                        <span className="absolute left-3 top-3 text-gray-500">₹</span>
                        <input
                          type="number"
                          id="maxInvestment"
                          name="maxInvestment"
                          value={formData.maxInvestment}
                          onChange={handleInputChange}
                          className={`block w-full pl-8 pr-4 py-3 border-2 rounded-lg shadow-sm text-sm transition-all duration-200 text-gray-900 placeholder-gray-500 ${
                            formErrors.maxInvestment
                              ? 'border-red-300 focus:ring-red-500 focus:border-red-500 bg-red-50'
                              : 'border-gray-300 focus:ring-blue-500 focus:border-blue-500 hover:border-blue-400'
                          }`}
                          placeholder="5000"
                          min="100"
                          required
                        />
                      </div>
                      {formErrors.maxInvestment && (
                        <p className="mt-2 text-sm text-red-600 flex items-center">
                          <svg className="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                            <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clipRule="evenodd" />
                          </svg>
                          {formErrors.maxInvestment}
                        </p>
                      )}
                    </div>

                    <div>
                      <label htmlFor="expectedROI" className="block text-sm font-semibold text-gray-700 mb-2">
                        Expected ROI (%) <span className="text-red-500">*</span>
                      </label>
                      <div className="relative">
                        <input
                          type="number"
                          id="expectedROI"
                          name="expectedROI"
                          value={formData.expectedROI}
                          onChange={handleInputChange}
                          className={`block w-full pr-8 pl-4 py-3 border-2 rounded-lg shadow-sm text-sm transition-all duration-200 text-gray-900 placeholder-gray-500 ${
                            formErrors.expectedROI
                              ? 'border-red-300 focus:ring-red-500 focus:border-red-500 bg-red-50'
                              : 'border-gray-300 focus:ring-blue-500 focus:border-blue-500 hover:border-blue-400'
                          }`}
                          placeholder="15.5"
                          min="0"
                          max="100"
                          step="0.1"
                          required
                        />
                        <span className="absolute right-3 top-3 text-gray-500">%</span>
                      </div>
                      {formErrors.expectedROI && (
                        <p className="mt-2 text-sm text-red-600 flex items-center">
                          <svg className="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                            <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clipRule="evenodd" />
                          </svg>
                          {formErrors.expectedROI}
                        </p>
                      )}
                    </div>
                  </div>
                </div>

                {/* Campaign Settings Section */}
                <div className="bg-green-50 rounded-lg p-6">
                  <h4 className="text-lg font-semibold text-gray-900 mb-4 flex items-center">
                    <svg className="w-5 h-5 mr-2 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                    </svg>
                    Campaign Settings
                  </h4>

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div>
                      <label htmlFor="duration" className="block text-sm font-semibold text-gray-700 mb-2">
                        Campaign Duration (days) <span className="text-red-500">*</span>
                      </label>
                      <input
                        type="number"
                        id="duration"
                        name="duration"
                        value={formData.duration}
                        onChange={handleInputChange}
                        className={`block w-full px-4 py-3 border-2 rounded-lg shadow-sm text-sm transition-all duration-200 text-gray-900 placeholder-gray-500 ${
                          formErrors.duration
                            ? 'border-red-300 focus:ring-red-500 focus:border-red-500 bg-red-50'
                            : 'border-gray-300 focus:ring-green-500 focus:border-green-500 hover:border-green-400'
                        }`}
                        placeholder="90"
                        min="30"
                        max="365"
                        required
                      />
                      {formErrors.duration && (
                        <p className="mt-2 text-sm text-red-600 flex items-center">
                          <svg className="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                            <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clipRule="evenodd" />
                          </svg>
                          {formErrors.duration}
                        </p>
                      )}
                    </div>

                    <div>
                      <label htmlFor="dailyRepaymentPercentage" className="block text-sm font-semibold text-gray-700 mb-2">
                        Daily Repayment (% of revenue) <span className="text-red-500">*</span>
                      </label>
                      <div className="relative">
                        <input
                          type="number"
                          id="dailyRepaymentPercentage"
                          name="dailyRepaymentPercentage"
                          value={formData.dailyRepaymentPercentage}
                          onChange={handleInputChange}
                          className={`block w-full pr-8 pl-4 py-3 border-2 rounded-lg shadow-sm text-sm transition-all duration-200 text-gray-900 placeholder-gray-500 ${
                            formErrors.dailyRepaymentPercentage
                              ? 'border-red-300 focus:ring-red-500 focus:border-red-500 bg-red-50'
                              : 'border-gray-300 focus:ring-green-500 focus:border-green-500 hover:border-green-400'
                          }`}
                          placeholder="5.0"
                          min="0"
                          max="50"
                          step="0.1"
                          required
                        />
                        <span className="absolute right-3 top-3 text-gray-500">%</span>
                      </div>
                      {formErrors.dailyRepaymentPercentage && (
                        <p className="mt-2 text-sm text-red-600 flex items-center">
                          <svg className="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                            <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clipRule="evenodd" />
                          </svg>
                          {formErrors.dailyRepaymentPercentage}
                        </p>
                      )}
                    </div>

                    <div>
                      <label htmlFor="endDate" className="block text-sm font-semibold text-gray-700 mb-2">
                        Expected End Date <span className="text-red-500">*</span>
                      </label>
                      <input
                        type="date"
                        id="endDate"
                        name="endDate"
                        value={formData.endDate}
                        onChange={handleInputChange}
                        className={`block w-full px-4 py-3 border-2 rounded-lg shadow-sm text-sm transition-all duration-200 text-gray-900 ${
                          formErrors.endDate
                            ? 'border-red-300 focus:ring-red-500 focus:border-red-500 bg-red-50'
                            : 'border-gray-300 focus:ring-green-500 focus:border-green-500 hover:border-green-400'
                        }`}
                        required
                      />
                      {formErrors.endDate && (
                        <p className="mt-2 text-sm text-red-600 flex items-center">
                          <svg className="w-4 h-4 mr-1" fill="currentColor" viewBox="0 0 20 20">
                            <path fillRule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clipRule="evenodd" />
                          </svg>
                          {formErrors.endDate}
                        </p>
                      )}
                    </div>
                  </div>
                </div>
              </div>

              {/* Action Buttons */}
              <div className="flex flex-col sm:flex-row justify-end space-y-3 sm:space-y-0 sm:space-x-4 pt-8 border-t border-gray-200">
                <button
                  type="button"
                  onClick={() => setShowCreateModal(false)}
                  className="w-full sm:w-auto px-6 py-3 border-2 border-gray-300 rounded-lg text-sm font-semibold text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-500 transition-all duration-200"
                  disabled={submitting}
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={submitting}
                  className="w-full sm:w-auto px-6 py-3 border-2 border-transparent rounded-lg shadow-sm text-sm font-semibold text-white bg-gradient-to-r from-indigo-600 to-blue-600 hover:from-indigo-700 hover:to-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200 flex items-center justify-center"
                >
                  {submitting ? (
                    <>
                      <svg className="animate-spin -ml-1 mr-3 h-5 w-5 text-white" fill="none" viewBox="0 0 24 24">
                        <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                        <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                      </svg>
                      Creating Campaign...
                    </>
                  ) : (
                    <>
                      <svg className="-ml-1 mr-3 h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
                      </svg>
                      Create Campaign
                    </>
                  )}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Create Shop Modal */}
      {showCreateShopModal && (
        <div className="fixed inset-0 bg-black bg-opacity-50 overflow-y-auto h-full w-full z-50 flex items-center justify-center p-4">
          <div className="relative bg-white w-full max-w-lg mx-auto rounded-lg shadow-xl">
            <div className="px-6 py-4 border-b border-gray-200">
              <div className="flex justify-between items-center">
                <h3 className="text-xl font-semibold text-gray-900">Create New Shop</h3>
                <button
                  onClick={() => setShowCreateShopModal(false)}
                  className="text-gray-400 hover:text-gray-600 transition-colors duration-200"
                  aria-label="Close modal"
                >
                  <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>
            </div>

            <form onSubmit={handleCreateShop} className="px-6 py-6 space-y-6">
              <div>
                <label htmlFor="shopName" className="block text-sm font-medium text-gray-700 mb-2">
                  Shop Name <span className="text-red-500">*</span>
                </label>
                <input
                  type="text"
                  id="shopName"
                  name="name"
                  value={shopFormData.name}
                  onChange={handleShopInputChange}
                  className={`block w-full px-3 py-2 border rounded-md shadow-sm focus:outline-none focus:ring-2 sm:text-sm transition-colors duration-200 text-gray-900 placeholder-gray-500 ${
                    shopFormErrors.name
                      ? 'border-red-300 focus:ring-red-500 focus:border-red-500'
                      : 'border-gray-300 focus:ring-green-500 focus:border-green-500'
                  }`}
                  placeholder="Enter shop name"
                  required
                />
                {shopFormErrors.name && (
                  <p className="mt-1 text-sm text-red-600">{shopFormErrors.name}</p>
                )}
              </div>

              <div>
                <label htmlFor="shopEmail" className="block text-sm font-medium text-gray-700 mb-2">
                  Email Address <span className="text-red-500">*</span>
                </label>
                <input
                  type="email"
                  id="shopEmail"
                  name="email"
                  value={shopFormData.email}
                  onChange={handleShopInputChange}
                  className={`block w-full px-3 py-2 border rounded-md shadow-sm focus:outline-none focus:ring-2 sm:text-sm transition-colors duration-200 text-gray-900 placeholder-gray-500 ${
                    shopFormErrors.email
                      ? 'border-red-300 focus:ring-red-500 focus:border-red-500'
                      : 'border-gray-300 focus:ring-green-500 focus:border-green-500'
                  }`}
                  placeholder="shop@example.com"
                  required
                />
                {shopFormErrors.email && (
                  <p className="mt-1 text-sm text-red-600">{shopFormErrors.email}</p>
                )}
              </div>

              <div>
                <label htmlFor="shopOwner" className="block text-sm font-medium text-gray-700 mb-2">
                  Owner Name <span className="text-red-500">*</span>
                </label>
                <input
                  type="text"
                  id="shopOwner"
                  name="owner"
                  value={shopFormData.owner}
                  onChange={handleShopInputChange}
                  className={`block w-full px-3 py-2 border rounded-md shadow-sm focus:outline-none focus:ring-2 sm:text-sm transition-colors duration-200 text-gray-900 placeholder-gray-500 ${
                    shopFormErrors.owner
                      ? 'border-red-300 focus:ring-red-500 focus:border-red-500'
                      : 'border-gray-300 focus:ring-green-500 focus:border-green-500'
                  }`}
                  placeholder="Enter owner's full name"
                  required
                />
                {shopFormErrors.owner && (
                  <p className="mt-1 text-sm text-red-600">{shopFormErrors.owner}</p>
                )}
              </div>

              <div>
                <label htmlFor="shopLocation" className="block text-sm font-medium text-gray-700 mb-2">
                  Location <span className="text-gray-500">(Optional)</span>
                </label>
                <input
                  type="text"
                  id="shopLocation"
                  name="location"
                  value={shopFormData.location}
                  onChange={handleShopInputChange}
                  className="block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-green-500 sm:text-sm transition-colors duration-200 text-gray-900 placeholder-gray-500"
                  placeholder="City, State (e.g., Mumbai, Maharashtra)"
                />
              </div>

              <div>
                <label htmlFor="avgUpiTransactions" className="block text-sm font-medium text-gray-700 mb-2">
                  Average UPI Transactions per Day <span className="text-gray-500">(Optional)</span>
                </label>
                <input
                  type="number"
                  id="avgUpiTransactions"
                  name="avgUpiTransactions"
                  value={shopFormData.avgUpiTransactions}
                  onChange={handleShopInputChange}
                  className="block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-green-500 focus:border-green-500 sm:text-sm transition-colors duration-200 text-gray-900 placeholder-gray-500"
                  placeholder="e.g., 5000"
                  min="0"
                  step="0.01"
                />
              </div>

              <div className="flex justify-end space-x-3 pt-4 border-t border-gray-200">
                <button
                  type="button"
                  onClick={() => setShowCreateShopModal(false)}
                  className="px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 transition-colors duration-200"
                  disabled={submitting}
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={submitting}
                  className="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 disabled:opacity-50 disabled:cursor-not-allowed transition-colors duration-200"
                >
                  {submitting ? (
                    <div className="flex items-center">
                      <svg className="animate-spin -ml-1 mr-2 h-4 w-4 text-white" fill="none" viewBox="0 0 24 24">
                        <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                        <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                      </svg>
                      Creating...
                    </div>
                  ) : (
                    'Create Shop'
                  )}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
