import { LayoutGrid, UtensilsCrossed, User } from 'lucide-react';

type NavigationProps = {
  currentScreen: 'tables' | 'menu' | 'profile';
  setCurrentScreen: (screen: 'tables' | 'menu' | 'profile') => void;
};

export default function Navigation({ currentScreen, setCurrentScreen }: NavigationProps) {
  const navItems = [
    { id: 'tables' as const, label: 'Столы', icon: LayoutGrid },
    { id: 'menu' as const, label: 'Меню', icon: UtensilsCrossed },
    { id: 'profile' as const, label: 'Профиль', icon: User },
  ];

  return (
    <nav className="fixed bottom-0 left-0 right-0 bg-white dark:bg-gray-800 border-t border-gray-200 dark:border-gray-700 px-4 py-2 max-w-md mx-auto">
      <div className="flex items-center justify-around">
        {navItems.map((item) => {
          const Icon = item.icon;
          const isActive = currentScreen === item.id;
          
          return (
            <button
              key={item.id}
              onClick={() => setCurrentScreen(item.id)}
              className={`flex flex-col items-center gap-1 px-4 py-2 rounded-lg transition-colors ${
                isActive 
                  ? 'text-orange-500 bg-orange-50 dark:bg-orange-950' 
                  : 'text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-300'
              }`}
            >
              <Icon className="size-6" />
              <span className="text-xs">{item.label}</span>
            </button>
          );
        })}
      </div>
    </nav>
  );
}