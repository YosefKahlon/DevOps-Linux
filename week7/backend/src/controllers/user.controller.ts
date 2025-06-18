import { Request, Response } from 'express';
import * as userService from '../services/user.service';

export const getAll = async (req: Request, res: Response) => {
  const users = await userService.getUsers();
  res.json(users);
};

export const getOne = async (req: Request, res: Response) => {
  const user = await userService.getUserById(Number(req.params.id));
  user ? res.json(user) : res.status(404).json({ message: 'User not found' });
};

export const create = async (req: Request, res: Response) => {
  const newUser = await userService.createUser(req.body);
  res.status(201).json(newUser);
};

export const update = async (req: Request, res: Response) => {
  const updatedUser = await userService.updateUser(Number(req.params.id), req.body);
  updatedUser ? res.json(updatedUser) : res.status(404).json({ message: 'User not found' });
};

export const remove = async (req: Request, res: Response) => {
  await userService.deleteUser(Number(req.params.id));
  res.status(204).send();
};
