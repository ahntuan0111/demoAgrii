const Product = require('./product.model');
const User = require('../users/user.model'); 

// @desc    Lấy tất cả sản phẩm (với filter)
// @route   GET /api/v1/products
exports.getProducts = async (req, res) => {
  try {
    const pageSize = 10; 
    const page = Number(req.query.page) || 1; 
    
    const filter = {};

    if (req.query.category) {
      filter.category = req.query.category;
    }
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
    const { name, description, images, price, quantity, category, brand, packageOptions, videoUrl } = req.body;
    
    const product = new Product({
      name,
      description,
      images,
      price,
      quantity,
      category,
      brand,
      packageOptions,
      videoUrl
      // user: req.user._id, // Gán người tạo
    });

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

    const brands = await Product.distinct('brand', { 
      category: category, 
      status: 'active' 
    });

    res.json(brands); 

  } catch (error) {
    console.error('Lỗi khi lấy brands:', error);
    res.status(500).json({ message: 'Lỗi server' });
  }
};