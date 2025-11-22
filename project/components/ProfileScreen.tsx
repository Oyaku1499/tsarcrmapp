import { ImageWithFallback } from './figma/ImageWithFallback';
import { Button } from './ui/button';
import { Card } from './ui/card';
import { Label } from './ui/label';
import { Switch } from './ui/switch';
import { LogOut, Mail, Phone, Briefcase, Moon, Sun } from 'lucide-react';
import type { Employee } from '../App';

type ProfileScreenProps = {
  employee: Employee | null;
  onLogout: () => void;
  isDarkMode: boolean;
  setIsDarkMode: (value: boolean) => void;
};

export default function ProfileScreen({ employee, onLogout, isDarkMode, setIsDarkMode }: ProfileScreenProps) {
  if (!employee) return null;

  return (
    <div className="p-4 space-y-4">
      <h2 className="dark:text-white">Профиль</h2>

      <Card className="p-6 space-y-6 dark:bg-gray-800 dark:border-gray-700">
        <div className="flex flex-col items-center">
          <ImageWithFallback
            src={`https://source.unsplash.com/200x200/?${employee.avatar}`}
            alt={employee.name}
            className="size-24 rounded-full object-cover mb-4"
          />
          <h2 className="text-center dark:text-white">{employee.name}</h2>
          <div className="flex items-center gap-2 mt-2">
            <Briefcase className="size-4 text-gray-500 dark:text-gray-400" />
            <p className="text-gray-600 dark:text-gray-300">{employee.role}</p>
          </div>
        </div>

        <div className="space-y-4 border-t dark:border-gray-700 pt-4">
          <div className="flex items-center gap-3">
            <Mail className="size-5 text-gray-400" />
            <div>
              <p className="text-sm text-gray-500 dark:text-gray-400">Email</p>
              <p className="dark:text-gray-200">{employee.email}</p>
            </div>
          </div>

          <div className="flex items-center gap-3">
            <Phone className="size-5 text-gray-400" />
            <div>
              <p className="text-sm text-gray-500 dark:text-gray-400">Телефон</p>
              <p className="dark:text-gray-200">{employee.phone}</p>
            </div>
          </div>
        </div>

        <Button 
          onClick={onLogout} 
          variant="outline" 
          className="w-full border-red-200 text-red-600 hover:bg-red-50 dark:border-red-800 dark:text-red-400 dark:hover:bg-red-950"
        >
          <LogOut className="size-4 mr-2" />
          Выйти из аккаунта
        </Button>
      </Card>

      <Card className="p-4 dark:bg-gray-800 dark:border-gray-700">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            {isDarkMode ? (
              <Moon className="size-5 text-orange-500" />
            ) : (
              <Sun className="size-5 text-orange-500" />
            )}
            <div>
              <Label className="dark:text-white">Тема оформления</Label>
              <p className="text-sm text-gray-500 dark:text-gray-400">
                {isDarkMode ? 'Темная' : 'Светлая'}
              </p>
            </div>
          </div>
          <Switch
            checked={isDarkMode}
            onCheckedChange={setIsDarkMode}
          />
        </div>
      </Card>

      <Card className="p-4 bg-orange-50 border-orange-200 dark:bg-orange-950 dark:border-orange-900">
        <h3 className="mb-2 dark:text-orange-100">Информация</h3>
        <p className="text-sm text-gray-600 dark:text-gray-400">
          Это демо версия CRM системы. Все данные хранятся локально и сбрасываются при обновлении страницы.
        </p>
      </Card>
    </div>
  );
}