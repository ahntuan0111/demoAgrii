const Product = require('./product.model');
// const User = require('../users/user.model'); // (Không được sử dụng, có thể xóa)

// @desc    Lấy tất cả sản phẩm (với filter)
// @route   GET /api/v1/products
exports.getProducts = async (req, res) => {
  try {
    const pageSize = 10; 
    const page = Number(req.query.page) || 1; 
    
    const filter = {};

    // --- ✅ SỬA LỖI LOGIC TẠI ĐÂY ---
    // Chỉ lọc 'category' NẾU nó được cung cấp VÀ nó KHÔNG PHẢI là 'all'
    if (req.query.category && req.query.category !== 'all') {
      filter.category = req.query.category;
    }
    // ---------------------------------

    if (req.query.brand) {
      const brands = Array.isArray(req.query.brand) ? req.query.brand : [req.query.brand];
      filter.brand = { $in: brands };
    }
    if (req.query.minPrice || req.query.maxPrice) {
      filter.price = {};
      if (req.query.minPrice) {
        filter.price.$gte = Number(req.query.minPrice); // >=
      }
      if (req.query.maxPrice) {
        filter.price.$lte = Number(req.query.maxPrice); // <=
      }
    }
    if (req.query.search) {
      filter.name = {
        $regex: req.query.search, 
        $options: 'i', 
      };
    }
    filter.status = 'active';

    const count = await Product.countDocuments(filter); 
    const products = await Product.find(filter)
      .limit(pageSize)
      .skip(pageSize * (page - 1));

    res.json({
      products,
      page,
      pages: Math.ceil(count / pageSize), 
      total: count, 
    });

  } catch (error) {
    console.error('Lỗi khi lấy sản phẩm:', error);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

// @desc    Lấy chi tiết 1 sản phẩm
// @route   GET /api/v1/products/:id
exports.getProductById = async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);
    if (!product) {
      return res.status(404).json({ message: 'Không tìm thấy sản phẩm' });
    }
    res.json(product);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server' });
  }
};

// @desc    Tạo sản phẩm mới
// @route   POST /api/v1/products
exports.createProduct = async (req, res) => {
  try {
    // --- ✅ SỬA LỖI LOGIC TẠI ĐÂY ---
    // (Model của bạn dùng 'variants', không dùng 'packageOptions' hay 'quantity' ở cấp cao nhất)
    const { name, description, images, price, category, brand, variants, videoUrl } = req.body;
    
    const product = new Product({
      name,
      description,
      images,
      price,
      // quantity, // (Trường này nằm bên trong 'variants')
      category,
      brand,
      variants: variants, // (Đổi 'packageOptions' thành 'variants')
      videoUrl
      // user: req.user._id, // Gán người tạo
    });
    // ---------------------------------

    const createdProduct = await product.save();
    res.status(201).json(createdProduct);
  } catch (error) {
    res.status(400).json({ message: 'Tạo sản phẩm thất bại', error: error.message });
  }
};

// @desc    Lấy danh sách brand duy nhất theo category
// @route   GET /api/v1/products/brands
exports.getBrandsByCategory = async (req, res) => {
  try {
    const { category } = req.query;

    if (!category) {
      return res.status(400).json({ message: 'Vui lòng cung cấp category' });
    }

    // --- ✅ SỬA LỖI LOGIC TẠI ĐÂY ---
    // (Thêm logic 'all' giống như getProducts)
    const filter = { status: 'active' };
    if (category && category !== 'all') {
      filter.category = category;
    }
    // ---------------------------------

    const brands = await Product.distinct('brand', filter);

    res.json(brands); 

  } catch (error) {
    console.error('Lỗi khi lấy brands:', error);
    res.status(500).json({ message: 'Lỗi server' });
  }
};