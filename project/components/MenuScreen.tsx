import { useState } from 'react';
import { ImageWithFallback } from './figma/ImageWithFallback';
import { Badge } from './ui/badge';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from './ui/dialog';
import { Search, ListFilter } from 'lucide-react';
import type { MenuItem } from '../App';

type MenuScreenProps = {
  menuItems: MenuItem[];
};

export default function MenuScreen({ menuItems }: MenuScreenProps) {
  const [selectedCategory, setSelectedCategory] = useState('all');
  const [searchQuery, setSearchQuery] = useState('');
  const [isCategoriesOpen, setIsCategoriesOpen] = useState(false);

  const categories = Array.from(new Set(menuItems.map(item => item.category)));

  const filteredItems = menuItems.filter(item => {
    const matchesCategory = selectedCategory === 'all' || item.category === selectedCategory;
    const matchesSearch = item.name.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesCategory && matchesSearch;
  });

  const handleCategorySelect = (category: string) => {
    setSelectedCategory(category);
    setIsCategoriesOpen(false);
  };

  const getCategoryLabel = () => {
    return selectedCategory === 'all' ? 'Полное меню' : selectedCategory;
  };

  return (
    <div className="p-4">
      <h2 className="mb-4 dark:text-white">Меню</h2>

      {/* Поиск */}
      <div className="mb-4 relative">
        <Search className="absolute left-3 top-1/2 -translate-y-1/2 size-5 text-gray-400" />
        <Input
          type="text"
          placeholder="Поиск блюда..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          className="pl-10"
        />
      </div>

      {/* Кнопки фильтров */}
      <div className="flex gap-2 mb-4">
        <Button
          variant={selectedCategory === 'all' ? 'default' : 'outline'}
          onClick={() => setSelectedCategory('all')}
          className={selectedCategory === 'all' ? 'bg-orange-500 hover:bg-orange-600' : ''}
        >
          Полное меню
        </Button>

        <Dialog open={isCategoriesOpen} onOpenChange={setIsCategoriesOpen}>
          <DialogTrigger asChild>
            <Button variant="outline" className="flex-1">
              <ListFilter className="size-4 mr-2" />
              {selectedCategory !== 'all' ? getCategoryLabel() : 'Категории'}
            </Button>
          </DialogTrigger>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>Выберите категорию</DialogTitle>
            </DialogHeader>
            <div className="space-y-2">
              {categories.map((category) => (
                <Button
                  key={category}
                  variant={selectedCategory === category ? 'default' : 'outline'}
                  className={`w-full justify-start ${selectedCategory === category ? 'bg-orange-500 hover:bg-orange-600' : ''}`}
                  onClick={() => handleCategorySelect(category)}
                >
                  {category}
                </Button>
              ))}
            </div>
          </DialogContent>
        </Dialog>
      </div>

      {/* Список блюд */}
      <div className="space-y-3">
        {filteredItems.map((item) => (
          <div key={item.id} className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 overflow-hidden">
            <div className="flex gap-3 p-3">
              <ImageWithFallback
                src={`https://source.unsplash.com/120x120/?${item.image}`}
                alt={item.name}
                className="size-24 object-cover rounded-lg flex-shrink-0"
              />
              <div className="flex-1 min-w-0">
                <div className="flex items-start justify-between gap-2 mb-1">
                  <h3 className="truncate dark:text-white">{item.name}</h3>
                  <Badge variant="secondary" className="flex-shrink-0 dark:bg-gray-700 dark:text-gray-300">
                    {item.price} ₽
                  </Badge>
                </div>
                <Badge className="mb-2 bg-orange-100 text-orange-800 dark:bg-orange-900 dark:text-orange-200">
                  {item.category}
                </Badge>
                <p className="text-sm text-gray-600 dark:text-gray-300 line-clamp-2">
                  {item.description}
                </p>
              </div>
            </div>
          </div>
        ))}
      </div>

      {filteredItems.length === 0 && (
        <div className="text-center py-12 text-gray-400 dark:text-gray-500">
          <p>Блюда не найдены</p>
        </div>
      )}
    </div>
  );
}