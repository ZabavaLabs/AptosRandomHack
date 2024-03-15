import React from 'react';

interface Tab {
    label: string;
    content: React.ReactNode;
}

interface TabsProps {
    tabs: Tab[];
    activeTab: number;
    setActiveTab: React.Dispatch<React.SetStateAction<number>>;
}

const Tabs: React.FC<TabsProps> = ({ tabs, activeTab, setActiveTab }) => {
    return (
        <div className="flex">
            {tabs.map((tab, index) => (
                <button
                    key={index}
                    className={`mr-4 px-4 py-2 ${activeTab === index ? 'bg-blue-500 text-white' : 'bg-gray-200 text-gray-700'
                        }`}
                    onClick={() => setActiveTab(index)}
                >
                    {tab.label}
                </button>
            ))}
        </div>
    );
};

export default Tabs;