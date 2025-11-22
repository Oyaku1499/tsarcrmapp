import { useState } from 'react';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { UtensilsCrossed } from 'lucide-react';
import type { Employee } from '../App';

type LoginScreenProps = {
  onLogin: (employee: Employee) => void;
};

export default function LoginScreen({ onLogin }: LoginScreenProps) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    // Mock authentication
    const mockEmployee: Employee = {
      id: '1',
      name: 'Анна Смирнова',
      role: 'Официант',
      email: email || 'anna@restaurant.com',
      phone: '+7 999 888-77-66',
      avatar: 'female server'
    };
    
    onLogin(mockEmployee);
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-orange-50 to-orange-100 flex items-center justify-center p-4">
      <div className="w-full max-w-md">
        <div className="bg-white rounded-2xl shadow-xl p-8">
          <div className="flex flex-col items-center mb-8">
            <div className="bg-orange-500 rounded-full p-4 mb-4">
              <UtensilsCrossed className="size-8 text-white" />
            </div>
            <h1 className="text-center mb-2">Restaurant CRM</h1>
            <p className="text-gray-500 text-center">Вход для сотрудников</p>
          </div>

          <form onSubmit={handleSubmit} className="space-y-6">
            <div className="space-y-2">
              <Label htmlFor="email">Email</Label>
              <Input
                id="email"
                type="email"
                placeholder="your.email@restaurant.com"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="password">Пароль</Label>
              <Input
                id="password"
                type="password"
                placeholder="••••••••"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
            </div>

            <Button type="submit" className="w-full bg-orange-500 hover:bg-orange-600">
              Войти
            </Button>
          </form>

          <p className="text-center text-gray-400 mt-6 text-sm">
            Демо: используйте любой email и пароль
          </p>
        </div>
      </div>
    </div>
  );
}
