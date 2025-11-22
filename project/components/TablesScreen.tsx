import { useState } from 'react';
import { ImageWithFallback } from './figma/ImageWithFallback';
import { Button } from './ui/button';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from './ui/dialog';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from './ui/select';
import { Badge } from './ui/badge';
import { Plus, Trash2, ShoppingCart, Search, ListFilter } from 'lucide-react';
import type { Table, MenuItem } from '../App';

type TablesScreenProps = {
  tables: Table[];
  setTables: (tables: Table[]) => void;
  menuItems: MenuItem[];
};

type OrderPosition = {
  id: string;
  items: { menuItem: MenuItem; quantity: number }[];
};

export default function TablesScreen({ tables, setTables, menuItems }: TablesScreenProps) {
  const [isAddTableOpen, setIsAddTableOpen] = useState(false);
  const [isOrderOpen, setIsOrderOpen] = useState(false);
  const [selectedTable, setSelectedTable] = useState<Table | null>(null);

  const [newTableNumber, setNewTableNumber] = useState('1');
  const [newTableSeats, setNewTableSeats] = useState('4');
  const [orderPositions, setOrderPositions] = useState<OrderPosition[]>([{ id: '1', items: [] }]);
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const [currentPositionId, setCurrentPositionId] = useState<string | null>(null);
  const [menuSearchQuery, setMenuSearchQuery] = useState('');
  const [menuSelectedCategory, setMenuSelectedCategory] = useState('all');
  const [isCategoriesOpen, setIsCategoriesOpen] = useState(false);
  const [tempSelectedItems, setTempSelectedItems] = useState<{ menuItem: MenuItem; quantity: number }[]>([]);

  const handleAddTable = () => {
    const newTable: Table = {
      id: String(Date.now()),
      number: parseInt(newTableNumber),
      seats: parseInt(newTableSeats),
      status: 'free',
    };
    setTables([...tables, newTable]);
    setIsAddTableOpen(false);
    setNewTableNumber('1');
    setNewTableSeats('4');
  };

  const handleDeleteTable = (id: string) => {
    setTables(tables.filter(t => t.id !== id));
  };

  const handleAddOrder = () => {
    if (!selectedTable) return;
    const allItems = orderPositions.flatMap(pos => pos.items);
    if (allItems.length === 0) return;
    
    const total = allItems.reduce((sum, item) => sum + (item.menuItem.price * item.quantity), 0);
    const order = {
      id: String(Date.now()),
      items: allItems.map(item => ({
        name: item.menuItem.name,
        quantity: item.quantity,
        price: item.menuItem.price
      })),
      total
    };
    const updatedTables = tables.map(t => 
      t.id === selectedTable.id 
        ? { ...t, status: 'occupied' as const, order }
        : t
    );
    setTables(updatedTables);
    setIsOrderOpen(false);
    setSelectedTable(null);
    setOrderPositions([{ id: '1', items: [] }]);
  };

  const handleDeleteOrder = (id: string) => {
    const updatedTables = tables.map(t => 
      t.id === id 
        ? { ...t, status: 'free' as const, order: undefined }
        : t
    );
    setTables(updatedTables);
  };

  const addItemToOrder = (menuItemId: string) => {
    const menuItem = menuItems.find(m => m.id === menuItemId);
    if (!menuItem) return;
    
    const existingItem = tempSelectedItems.find(item => item.menuItem.id === menuItemId);
    if (existingItem) {
      setTempSelectedItems(tempSelectedItems.map(item =>
        item.menuItem.id === menuItemId
          ? { ...item, quantity: item.quantity + 1 }
          : item
      ));
    } else {
      setTempSelectedItems([...tempSelectedItems, { menuItem, quantity: 1 }]);
    }
  };

  const incrementTempItem = (menuItemId: string) => {
    setTempSelectedItems(tempSelectedItems.map(item =>
      item.menuItem.id === menuItemId
        ? { ...item, quantity: item.quantity + 1 }
        : item
    ));
  };

  const decrementTempItem = (menuItemId: string) => {
    const item = tempSelectedItems.find(i => i.menuItem.id === menuItemId);
    if (!item) return;
    
    if (item.quantity === 1) {
      setTempSelectedItems(tempSelectedItems.filter(i => i.menuItem.id !== menuItemId));
    } else {
      setTempSelectedItems(tempSelectedItems.map(i =>
        i.menuItem.id === menuItemId
          ? { ...i, quantity: i.quantity - 1 }
          : i
      ));
    }
  };

  const confirmTempItems = () => {
    if (!currentPositionId || tempSelectedItems.length === 0) return;
    
    setOrderPositions(orderPositions.map(pos => {
      if (pos.id !== currentPositionId) return pos;
      
      const newItems = [...pos.items];
      tempSelectedItems.forEach(tempItem => {
        const existingIndex = newItems.findIndex(item => item.menuItem.id === tempItem.menuItem.id);
        if (existingIndex >= 0) {
          newItems[existingIndex].quantity += tempItem.quantity;
        } else {
          newItems.push(tempItem);
        }
      });
      
      return { ...pos, items: newItems };
    }));
    
    setTempSelectedItems([]);
    setIsMenuOpen(false);
    setMenuSearchQuery('');
    setMenuSelectedCategory('all');
  };

  const removeItemFromPosition = (positionId: string, menuItemId: string) => {
    setOrderPositions(orderPositions.map(pos =>
      pos.id === positionId
        ? { ...pos, items: pos.items.filter(item => item.menuItem.id !== menuItemId) }
        : pos
    ));
  };

  const addNewPosition = () => {
    const newId = String(Date.now());
    setOrderPositions([...orderPositions, { id: newId, items: [] }]);
  };

  const removePosition = (positionId: string) => {
    if (orderPositions.length === 1) return; // Keep at least one position
    setOrderPositions(orderPositions.filter(pos => pos.id !== positionId));
  };

  const handleCategorySelect = (category: string) => {
    setMenuSelectedCategory(category);
    setIsCategoriesOpen(false);
  };

  const filteredMenuItems = menuItems.filter(item => {
    const matchesCategory = menuSelectedCategory === 'all' || item.category === menuSelectedCategory;
    const matchesSearch = item.name.toLowerCase().includes(menuSearchQuery.toLowerCase());
    return matchesCategory && matchesSearch;
  });

  const categories = Array.from(new Set(menuItems.map(item => item.category)));

  const getStatusColor = (status: Table['status']) => {
    switch (status) {
      case 'free':
        return 'bg-green-100 text-green-800';
      case 'occupied':
        return 'bg-red-100 text-red-800';
      case 'reserved':
        return 'bg-yellow-100 text-yellow-800';
    }
  };

  const getStatusText = (status: Table['status']) => {
    switch (status) {
      case 'free':
        return 'Свободен';
      case 'occupied':
        return 'Занят';
      case 'reserved':
        return 'Забронирован';
    }
  };

  return (
    <div className="p-4 space-y-4">
      <div className="flex items-center justify-between">
        <h2 className="dark:text-white">Управление столами</h2>
        <Dialog open={isAddTableOpen} onOpenChange={setIsAddTableOpen}>
          <DialogTrigger asChild>
            <Button size="sm" className="bg-orange-500 hover:bg-orange-600">
              <Plus className="size-4 mr-2" />
              Добавить стол
            </Button>
          </DialogTrigger>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>Новый стол</DialogTitle>
            </DialogHeader>
            <div className="space-y-4">
              <div className="space-y-2">
                <Label>Номер стола</Label>
                <Select value={newTableNumber} onValueChange={setNewTableNumber}>
                  <SelectTrigger>
                    <SelectValue placeholder="Выберите номер" />
                  </SelectTrigger>
                  <SelectContent>
                    {Array.from({ length: 25 }, (_, i) => i + 1).map((num) => (
                      <SelectItem key={num} value={String(num)}>
                        Стол {num}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              <div className="space-y-2">
                <Label>Количество мест</Label>
                <Input
                  type="number"
                  value={newTableSeats}
                  onChange={(e) => setNewTableSeats(e.target.value)}
                  min="1"
                />
              </div>
              <Button onClick={handleAddTable} className="w-full bg-orange-500 hover:bg-orange-600">
                Создать стол
              </Button>
            </div>
          </DialogContent>
        </Dialog>
      </div>

      <div className="grid grid-cols-2 gap-3">
        {tables.map((table) => (
          <div key={table.id} className="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-4 space-y-3">
            <div className="flex items-start justify-between">
              <div>
                <div className="flex items-center gap-2">
                  <h3 className="dark:text-white">Стол {table.number}</h3>
                  <Badge variant="secondary" className="text-xs dark:bg-gray-700 dark:text-gray-300">
                    {table.seats} мест
                  </Badge>
                </div>
                <Badge className={`mt-2 ${getStatusColor(table.status)}`}>
                  {getStatusText(table.status)}
                </Badge>
              </div>
              <Button
                variant="ghost"
                size="sm"
                onClick={() => handleDeleteTable(table.id)}
              >
                <Trash2 className="size-4 text-red-500" />
              </Button>
            </div>

            {table.order && (
              <div className="bg-red-50 dark:bg-red-950 rounded p-2 text-sm space-y-1">
                <p className="dark:text-red-100"><strong>Заказ #{table.order.id.slice(-4)}</strong></p>
                <div className="space-y-1">
                  {table.order.items.map((item, idx) => (
                    <p key={idx} className="text-gray-600 dark:text-gray-300">
                      {item.name} x{item.quantity}
                    </p>
                  ))}
                </div>
                <p className="border-t dark:border-red-900 pt-1 mt-1 dark:text-red-100">
                  <strong>Итого: {table.order.total} ₽</strong>
                </p>
                <Button
                  variant="outline"
                  size="sm"
                  className="w-full mt-2 dark:border-gray-600 dark:text-gray-200"
                  onClick={() => handleDeleteOrder(table.id)}
                >
                  Закрыть заказ
                </Button>
              </div>
            )}

            {table.status === 'free' && (
              <div className="space-y-2">
                <Dialog open={isOrderOpen && selectedTable?.id === table.id} onOpenChange={(open) => {
                  setIsOrderOpen(open);
                  if (open) {
                    setSelectedTable(table);
                    setCurrentPositionId('1');
                  } else {
                    setSelectedTable(null);
                    setOrderPositions([{ id: '1', items: [] }]);
                  }
                }}>
                  <DialogTrigger asChild>
                    <Button variant="outline" size="sm" className="w-full">
                      <ShoppingCart className="size-4 mr-2" />
                      Создать заказ
                    </Button>
                  </DialogTrigger>
                  <DialogContent className="max-h-[80vh] overflow-y-auto">
                    <DialogHeader>
                      <DialogTitle>Заказ для стола {table.number}</DialogTitle>
                    </DialogHeader>
                    <div className="space-y-4">
                      {/* Позиции */}
                      {orderPositions.map((position, index) => (
                        <div key={position.id} className="border rounded-lg p-3 space-y-3">
                          <div className="flex items-center justify-between">
                            <Label>Позиция {index + 1}</Label>
                            {orderPositions.length > 1 && (
                              <Button
                                variant="ghost"
                                size="sm"
                                onClick={() => removePosition(position.id)}
                              >
                                <Trash2 className="size-4 text-red-500" />
                              </Button>
                            )}
                          </div>
                          
                          {position.items.length > 0 && (
                            <div className="space-y-2">
                              {position.items.map((item) => (
                                <div key={item.menuItem.id} className="flex items-center justify-between bg-gray-50 rounded p-2">
                                  <div className="text-sm">
                                    <p>{item.menuItem.name}</p>
                                    <p className="text-gray-600">
                                      {item.quantity} x {item.menuItem.price} ₽ = {item.quantity * item.menuItem.price} ₽
                                    </p>
                                  </div>
                                  <Button
                                    variant="ghost"
                                    size="sm"
                                    onClick={() => removeItemFromPosition(position.id, item.menuItem.id)}
                                  >
                                    <Trash2 className="size-4 text-red-500" />
                                  </Button>
                                </div>
                              ))}
                            </div>
                          )}

                          <Dialog open={isMenuOpen && currentPositionId === position.id} onOpenChange={(open) => {
                            setIsMenuOpen(open);
                            if (!open) {
                              setTempSelectedItems([]);
                              setMenuSearchQuery('');
                              setMenuSelectedCategory('all');
                            }
                          }}>
                            <DialogTrigger asChild>
                              <Button 
                                variant="outline" 
                                size="sm" 
                                className="w-full"
                                onClick={() => setCurrentPositionId(position.id)}
                              >
                                <Plus className="size-4 mr-2" />
                                Добавить блюдо...
                              </Button>
                            </DialogTrigger>
                            <DialogContent className="max-h-[80vh] overflow-y-auto">
                              <DialogHeader>
                                <DialogTitle>Выбор блюда</DialogTitle>
                              </DialogHeader>
                              
                              {/* Поиск */}
                              <div className="relative">
                                <Search className="absolute left-3 top-1/2 -translate-y-1/2 size-5 text-gray-400" />
                                <Input
                                  type="text"
                                  placeholder="Поиск блюда..."
                                  value={menuSearchQuery}
                                  onChange={(e) => setMenuSearchQuery(e.target.value)}
                                  className="pl-10"
                                />
                              </div>

                              {/* Кнопки фильтров */}
                              <div className="flex gap-2">
                                <Button
                                  variant={menuSelectedCategory === 'all' ? 'default' : 'outline'}
                                  onClick={() => setMenuSelectedCategory('all')}
                                  size="sm"
                                  className={menuSelectedCategory === 'all' ? 'bg-orange-500 hover:bg-orange-600' : ''}
                                >
                                  Полное меню
                                </Button>

                                <Dialog open={isCategoriesOpen} onOpenChange={setIsCategoriesOpen}>
                                  <DialogTrigger asChild>
                                    <Button variant="outline" size="sm" className="flex-1">
                                      <ListFilter className="size-4 mr-2" />
                                      {menuSelectedCategory !== 'all' ? menuSelectedCategory : 'Категории'}
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
                                          variant={menuSelectedCategory === category ? 'default' : 'outline'}
                                          className={`w-full justify-start ${menuSelectedCategory === category ? 'bg-orange-500 hover:bg-orange-600' : ''}`}
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
                                {filteredMenuItems.map((item) => {
                                  const tempItem = tempSelectedItems.find(t => t.menuItem.id === item.id);
                                  
                                  return (
                                    <div 
                                      key={item.id} 
                                      className="border rounded-lg overflow-hidden"
                                    >
                                      <div 
                                        className="flex gap-3 p-3 cursor-pointer hover:bg-gray-50 transition-colors"
                                        onClick={() => !tempItem && addItemToOrder(item.id)}
                                      >
                                        <ImageWithFallback
                                          src={`https://source.unsplash.com/100x100/?${item.image}`}
                                          alt={item.name}
                                          className="size-20 object-cover rounded-lg flex-shrink-0"
                                        />
                                        <div className="flex-1 min-w-0">
                                          <div className="flex items-start justify-between gap-2 mb-1">
                                            <h4 className="truncate text-sm">{item.name}</h4>
                                            <Badge variant="secondary" className="flex-shrink-0 text-xs">
                                              {item.price} ₽
                                            </Badge>
                                          </div>
                                          <Badge className="mb-2 text-xs bg-orange-100 text-orange-800">
                                            {item.category}
                                          </Badge>
                                          <p className="text-xs text-gray-600 line-clamp-2">
                                            {item.description}
                                          </p>
                                        </div>
                                      </div>
                                      
                                      {tempItem && (
                                        <div className="border-t bg-gray-50 p-3 flex items-center justify-between">
                                          <Button
                                            variant="outline"
                                            size="sm"
                                            onClick={(e) => {
                                              e.stopPropagation();
                                              decrementTempItem(item.id);
                                            }}
                                            className="size-8 p-0"
                                          >
                                            -
                                          </Button>
                                          <span className="text-sm">{tempItem.quantity}</span>
                                          <Button
                                            variant="outline"
                                            size="sm"
                                            onClick={(e) => {
                                              e.stopPropagation();
                                              incrementTempItem(item.id);
                                            }}
                                            className="size-8 p-0"
                                          >
                                            +
                                          </Button>
                                        </div>
                                      )}
                                    </div>
                                  );
                                })}
                              </div>

                              {filteredMenuItems.length === 0 && (
                                <div className="text-center py-8 text-gray-400">
                                  <p>Блюда не найдены</p>
                                </div>
                              )}

                              {/* Кнопка "Добавить" */}
                              {tempSelectedItems.length > 0 && (
                                <div className="sticky bottom-0 bg-white border-t pt-4">
                                  <Button 
                                    onClick={confirmTempItems} 
                                    className="w-full bg-orange-500 hover:bg-orange-600"
                                  >
                                    Добавить ({tempSelectedItems.reduce((sum, item) => sum + item.quantity, 0)})
                                  </Button>
                                </div>
                              )}
                            </DialogContent>
                          </Dialog>
                        </div>
                      ))}

                      {/* Кнопка добавления позиции */}
                      <Button 
                        variant="outline" 
                        className="w-full"
                        onClick={addNewPosition}
                      >
                        <Plus className="size-4 mr-2" />
                        Добавить позицию
                      </Button>

                      {/* Итого */}
                      {orderPositions.some(pos => pos.items.length > 0) && (
                        <div className="border-t pt-4">
                          <p className="text-right">
                            <strong>
                              Общая сумма: {orderPositions.flatMap(pos => pos.items).reduce((sum, item) => sum + (item.menuItem.price * item.quantity), 0)} ₽
                            </strong>
                          </p>
                        </div>
                      )}

                      <Button 
                        onClick={handleAddOrder} 
                        className="w-full bg-orange-500 hover:bg-orange-600"
                        disabled={!orderPositions.some(pos => pos.items.length > 0)}
                      >
                        Создать заказ
                      </Button>
                    </div>
                  </DialogContent>
                </Dialog>
              </div>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}