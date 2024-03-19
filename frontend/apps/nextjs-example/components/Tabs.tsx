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
                    className={`mr-4 px-12 py-2 text-2xl ${activeTab === index ? ' text-white border-b-blue-500 border-b-4 font-bold' : 'font-normal text-gray-400 border-b-gray-700 border-b-0'
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