// Web版本的chafa调用 - 使用本地命令行
export async function runChafa(imagePath, options) {
  // 在Web版本中，我们需要通过API调用chafa
  // 这里我们先返回一个示例，实际使用时需要后端支持
  
  const formData = new FormData();
  formData.append('image', imagePath);
  formData.append('options', JSON.stringify(options));
  
  const response = await fetch('/api/convert', {
    method: 'POST',
    body: formData
  });
  
  if (!response.ok) {
    throw new Error('Conversion failed');
  }
  
  return await response.text();
}

export async function checkChafa() {
  try {
    const response = await fetch('/api/version');
    return await response.text();
  } catch (err) {
    throw new Error('Chafa not available');
  }
}
