export type Product = {
  name: string;
  price_czk: string | number;  // Accept both string and number from LLM
  image_link: string;
};

export type ChatPayload = {
  output_text: string;
  products: Product[] | null;
};
