using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IDamagable
{
    float m_health { get; set; }

    void Damage(float damage);
}
