import { useState, useEffect } from 'react';
import LoginScreen from './components/LoginScreen';
import TablesScreen from './components/TablesScreen';
import MenuScreen from './components/MenuScreen';
import ProfileScreen from './components/ProfileScreen';
import Navigation from './components/Navigation';

export type Table = {
  id: string;
  number: number;
  seats: number;
  status: 'free' | 'occupied';
  order?: {
    id: string;
    items: { name: string; quantity: number; price: number }[];
    total: number;
  };
};

export type MenuItem = {
  id: string;
  name: string;
  category: string;
  price: number;
  description: string;
  image: string;
};

export type Employee = {
  id: string;
  name: string;
  role: string;
  email: string;
  phone: string;
  avatar: string;
};

export default function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [currentScreen, setCurrentScreen] = useState<'tables' | 'menu' | 'profile'>('tables');
  const [currentEmployee, setCurrentEmployee] = useState<Employee | null>(null);
  const [isDarkMode, setIsDarkMode] = useState(false);

  useEffect(() => {
    // Load dark mode preference from localStorage
    const savedDarkMode = localStorage.getItem('darkMode') === 'true';
    setIsDarkMode(savedDarkMode);
    if (savedDarkMode) {
      document.documentElement.classList.add('dark');
    }
  }, []);

  useEffect(() => {
    // Apply or remove dark class
    if (isDarkMode) {
      document.documentElement.classList.add('dark');
      localStorage.setItem('darkMode', 'true');
    } else {
      document.documentElement.classList.remove('dark');
      localStorage.setItem('darkMode', 'false');
    }
  }, [isDarkMode]);

  const [tables, setTables] = useState<Table[]>([
    { id: '1', number: 1, seats: 4, status: 'free' },
    { id: '2', number: 2, seats: 2, status: 'occupied', order: { id: 'o1', items: [{ name: 'Паста Карбонара', quantity: 2, price: 450 }], total: 900 } },
    { id: '3', number: 3, seats: 6, status: 'free' },
    { id: '4', number: 4, seats: 4, status: 'free' },
  ]);

  const [menuItems] = useState<MenuItem[]>([
    { id: '1', name: 'Паста Карбонара', category: 'Основные блюда', price: 450, description: 'Классическая итальянская паста', image: 'pasta carbonara' },
    { id: '2', name: 'Цезарь с курицей', category: 'Салаты', price: 350, description: 'Свежий салат с курицей', image: 'caesar salad' },
    { id: '3', name: 'Стейк Рибай', category: 'Основные блюда', price: 1200, description: 'Сочный говяжий стейк', image: 'ribeye steak' },
    { id: '4', name: 'Том Ям', category: 'Супы', price: 400, description: 'Острый тайский суп', image: 'tom yum soup' },
    { id: '5', name: 'Тирамису', category: 'Десерты', price: 300, description: 'Итальянский десерт', image: 'tiramisu' },
    { id: '6', name: 'Капучино', category: 'Напитки', price: 180, description: 'Классический кофе', image: 'cappuccino' },
  ]);

  const handleLogin = (employee: Employee) => {
    setCurrentEmployee(employee);
    setIsAuthenticated(true);
  };

  const handleLogout = () => {
    setIsAuthenticated(false);
    setCurrentEmployee(null);
    setCurrentScreen('tables');
  };

  if (!isAuthenticated) {
    return <LoginScreen onLogin={handleLogin} />;
  }

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900 pb-20">
      <header className="bg-white dark:bg-gray-800 border-b border-gray-200 dark:border-gray-700 px-4 py-4 sticky top-0 z-10">
        <h1 className="text-center dark:text-white">Restaurant CRM</h1>
      </header>

      <main className="max-w-md mx-auto">
        {currentScreen === 'tables' && (
          <TablesScreen tables={tables} setTables={setTables} menuItems={menuItems} />
        )}
        {currentScreen === 'menu' && (
          <MenuScreen menuItems={menuItems} />
        )}
        {currentScreen === 'profile' && (
          <ProfileScreen 
            employee={currentEmployee} 
            onLogout={handleLogout}
            isDarkMode={isDarkMode}
            setIsDarkMode={setIsDarkMode}
          />
        )}
      </main>

      <Navigation currentScreen={currentScreen} setCurrentScreen={setCurrentScreen} />
    </div>
  );
}