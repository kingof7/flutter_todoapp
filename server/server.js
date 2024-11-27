const express = require('express');
const cors = require('cors');
const mysql = require('mysql2');

const app = express();
app.use(cors());
app.use(express.json());

// MySQL 연결 설정
const connection = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: 'root',
  database: 'todo'
});

// 연결 확인
connection.connect((err) => {
  if (err) {
    console.error('Error connecting to MySQL:', err);
    return;
  }
  console.log('Connected to MySQL database');
});

// 모든 할 일 가져오기
app.get('/api/todos', (req, res) => {
  connection.query('SELECT * FROM task_item', (error, results) => {
    if (error) {
      console.error('Error fetching todos:', error);
      res.status(500).json({ error: 'Failed to fetch todos' });
      return;
    }
    res.json(results);
  });
});

// 새로운 할 일 추가
app.post('/api/todos', (req, res) => {
  const { task } = req.body;
  if (!task) {
    res.status(400).json({ error: 'Task is required' });
    return;
  }

  connection.query(
    'INSERT INTO task_item (task) VALUES (?)',
    [task],
    (error, results) => {
      if (error) {
        console.error('Error adding todo:', error);
        res.status(500).json({ error: 'Failed to add todo' });
        return;
      }
      res.status(201).json({ id: results.insertId, task });
    }
  );
});

// 할 일 상태 토글
app.put('/api/todos/:id/toggle', (req, res) => {
  const { id } = req.params;
  connection.query(
    'UPDATE task_item SET is_done = CASE WHEN is_done = "Y" THEN "N" ELSE "Y" END WHERE id = ?',
    [id],
    (error) => {
      if (error) {
        console.error('Error toggling todo:', error);
        res.status(500).json({ error: 'Failed to toggle todo' });
        return;
      }
      // Get the updated todo item
      connection.query(
        'SELECT * FROM task_item WHERE id = ?',
        [id],
        (error, results) => {
          if (error) {
            console.error('Error getting updated todo:', error);
            res.status(500).json({ error: 'Failed to get updated todo' });
            return;
          }
          res.json(results[0]);
        }
      );
    }
  );
});

// 할 일 삭제
app.delete('/api/todos/:id', (req, res) => {
  const { id } = req.params;
  connection.query(
    'DELETE FROM task_item WHERE id = ?',
    [id],
    (error) => {
      if (error) {
        console.error('Error deleting todo:', error);
        res.status(500).json({ error: 'Failed to delete todo' });
        return;
      }
      res.json({ message: 'Todo deleted successfully' });
    }
  );
});

const PORT = 8080;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
