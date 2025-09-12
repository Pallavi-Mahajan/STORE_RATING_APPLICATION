import React, { useState, useEffect } from "react";
import axios from "axios";

function App() {
  const [form, setForm] = useState({ name: "", password: "", address: "", email: "" });
  const [stores, setStores] = useState([]);
  const [rating, setRating] = useState(0);

  useEffect(() => {
    fetchStores();
  }, []);

  const fetchStores = async () => {
    const res = await axios.get("http://localhost:5000/stores");
    setStores(res.data);
  };

  const registerStore = async () => {
    await axios.post("http://localhost:5000/register", form);
    fetchStores();
  };

  const rateStore = async (id) => {
    await axios.put(`http://localhost:5000/rate/${id}`, { rating });
    fetchStores();
  };

  return (
    <div style={{ padding: 20 }}>
      <h2>Register Store</h2>
      <input placeholder="Name" onChange={e => setForm({ ...form, name: e.target.value })} />
      <input placeholder="Password" type="password" onChange={e => setForm({ ...form, password: e.target.value })} />
      <input placeholder="Address" onChange={e => setForm({ ...form, address: e.target.value })} />
      <input placeholder="Email" onChange={e => setForm({ ...form, email: e.target.value })} />
      <button onClick={registerStore}>Register</button>

      <h2>Stores</h2>
      <ul>
        {stores.map(store => (
          <li key={store.id}>
            {store.name} | {store.email} | {store.address} | Rating: {store.rating}
            <input type="number" placeholder="Rate 1-5"
              onChange={e => setRating(e.target.value)} />
            <button onClick={() => rateStore(store.id)}>Rate</button>
          </li>
        ))}
      </ul>
    </div>
  );
}

export default App;
